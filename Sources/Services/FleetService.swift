import Foundation
import AppKit

/// Shows and controls the runner fleet supervisor (`mbp-supervisor`) from the
/// github-runners repository. The supervisor does the work; this only reads its
/// state and starts or stops its launch agent through the repository's script.
@MainActor
final class FleetService: ObservableObject {
    static let launchAgentLabel = "com.williamson-consulting.mbp-supervisor"
    static let repoPathKey = "fleetSupervisorRepoPath"
    nonisolated static let jobPrefix = "mbp-job-"

    struct Shape: Decodable, Identifiable, Sendable {
        let name: String
        let cpus: Int
        let memoryGB: Int
        var id: String { name }
    }

    struct ShapeRoom: Decodable, Identifiable, Sendable {
        let Shape: Shape
        let Fits: Int
        let Reason: String
        var id: String { Shape.name }
    }

    struct HostState: Decodable, Sendable {
        let AvailableBytes: Int64
        let Pressure: Int
        let Load5: Double
    }

    struct Capacity: Decodable, Sendable {
        let Host: HostState
        let UsedMemory: Int64
        let UsedCPUs: Int
        let RoomBytes: Int64
        let Shapes: [ShapeRoom]
    }

    struct Job: Identifiable, Sendable {
        let name: String
        let cpus: Int
        let memoryBytes: Int64
        var id: String { name }
        var shape: String {
            // mbp-job-<size>-<8hex>, where the shape is mbp-<size>
            let rest = name.dropFirst(FleetService.jobPrefix.count)
            return "mbp-" + rest.split(separator: "-").dropLast().joined(separator: "-")
        }
    }

    @Published private(set) var isInstalled = false
    @Published private(set) var agentRunning = false
    @Published private(set) var agentPID: Int?
    @Published private(set) var capacity: Capacity?
    @Published private(set) var jobs: [Job] = []
    @Published private(set) var lastError: String?
    @Published private(set) var busy = false

    private var timer: Timer?

    var repoPath: String {
        UserDefaults.standard.string(forKey: Self.repoPathKey)
            ?? (NSHomeDirectory() as NSString).appendingPathComponent("Repos/github-runners")
    }

    private var supervisorPath: String { (repoPath as NSString).appendingPathComponent("bin/mbp-supervisor") }
    private var configPath: String { (repoPath as NSString).appendingPathComponent("config/supervisor.json") }
    private var scriptPath: String { (repoPath as NSString).appendingPathComponent("scripts/launch-agent.sh") }
    static var logDirectory: URL {
        FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Logs/mbp-supervisor")
    }

    /// True when the github-runners clone and its built supervisor exist.
    var isAvailable: Bool { FileManager.default.isExecutableFile(atPath: supervisorPath) }

    func start() {
        guard timer == nil else { return }
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    func refresh() {
        guard isAvailable else { return }
        let supervisor = supervisorPath, config = configPath
        let label = Self.launchAgentLabel
        let plist = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents/\(label).plist").path
        Task.detached {
            let agent = Self.readAgent(label: label)
            let capacity = Self.readCapacity(supervisor: supervisor, config: config)
            let jobs = Self.readJobs()
            let installed = FileManager.default.fileExists(atPath: plist)
            await MainActor.run {
                self.isInstalled = installed
                self.agentRunning = agent.running
                self.agentPID = agent.pid
                if let capacity { self.capacity = capacity }
                self.jobs = jobs
            }
        }
    }

    /// Starts the supervisor under its launch agent, installing the agent if needed.
    func startSupervisor() { runScript(isInstalled ? "restart" : "install") }

    /// Stops the supervisor and removes its launch agent. Running jobs fail.
    func stopSupervisor() { runScript("uninstall") }

    func restartSupervisor() { runScript("restart") }

    func openLogs() { NSWorkspace.shared.open(Self.logDirectory) }

    func openSupervisorLog() {
        NSWorkspace.shared.open(Self.logDirectory.appendingPathComponent("supervisor.log"))
    }

    private func runScript(_ command: String) {
        let script = scriptPath
        busy = true
        lastError = nil
        Task.detached {
            let result = try? ProcessExecutor.run("/bin/sh", arguments: [script, command], timeout: 60)
            await MainActor.run {
                self.busy = false
                if result?.succeeded != true {
                    let out = result?.output.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    self.lastError = out.isEmpty ? "launch-agent.sh \(command) failed" : out
                }
                self.refresh()
            }
        }
    }

    // MARK: - Readers (run off the main actor)

    nonisolated private static func readAgent(label: String) -> (running: Bool, pid: Int?) {
        let target = "gui/\(getuid())/\(label)"
        guard let result = try? ProcessExecutor.run("/bin/launchctl", arguments: ["print", target], timeout: 5),
              result.succeeded else { return (false, nil) }
        var running = false
        var pid: Int?
        for line in result.output.split(separator: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed == "state = running" { running = true }
            if trimmed.hasPrefix("pid = "), let p = Int(trimmed.dropFirst(6)) { pid = p }
        }
        return (running, pid)
    }

    nonisolated private static func readCapacity(supervisor: String, config: String) -> Capacity? {
        guard let result = try? ProcessExecutor.run(
            supervisor, arguments: ["capacity", "-json", "-config", config], timeout: 20),
              result.succeeded,
              let data = result.output.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Capacity.self, from: data)
    }

    /// Lists runner containers only. Other containers, such as the operator's
    /// agent containers, are skipped by name and never inspected.
    nonisolated private static func readJobs() -> [Job] {
        guard let result = try? ProcessExecutor.run(
            "/usr/local/bin/container", arguments: ["list", "--format", "json"], timeout: 10),
              result.succeeded,
              let data = result.output.data(using: .utf8),
              let items = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return [] }
        return items.compactMap { item -> Job? in
            guard let config = item["configuration"] as? [String: Any],
                  let id = config["id"] as? String, id.hasPrefix(jobPrefix) else { return nil }
            let resources = config["resources"] as? [String: Any]
            let cpus = resources?["cpus"] as? Int ?? 0
            let memory = (resources?["memoryInBytes"] as? NSNumber)?.int64Value ?? 0
            return Job(name: id, cpus: cpus, memoryBytes: memory)
        }.sorted { $0.name < $1.name }
    }
}
