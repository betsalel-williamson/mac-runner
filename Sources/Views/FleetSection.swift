import SwiftUI

/// Menu bar section for the runner fleet supervisor: whether it runs, how many
/// runners of each size fit now, and the jobs running.
struct FleetSection: View {
    @EnvironmentObject var fleet: FleetService

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            header
            if let error = fleet.lastError {
                Text(error)
                    .font(.caption2)
                    .foregroundColor(.red)
                    .lineLimit(3)
            }
            if let capacity = fleet.capacity {
                hostLine(capacity)
                ForEach(capacity.Shapes) { room in
                    shapeRow(room, running: fleet.jobs.filter { $0.shape == room.Shape.name }.count)
                }
            }
            if !fleet.jobs.isEmpty {
                ForEach(fleet.jobs) { job in
                    HStack(spacing: 4) {
                        Image(systemName: "shippingbox")
                        Text(job.name).lineLimit(1).truncationMode(.middle)
                        Spacer(minLength: 0)
                        Text("\(job.cpus) vCPU")
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var header: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(fleet.agentRunning ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
            Text("Fleet")
                .font(.caption)
                .fontWeight(.semibold)
            Text(fleet.agentRunning ? "running" : (fleet.isInstalled ? "stopped" : "not installed"))
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            if fleet.busy {
                ProgressView().controlSize(.mini)
            }
            Menu {
                if fleet.agentRunning {
                    Button("Restart Supervisor") { fleet.restartSupervisor() }
                    Button("Stop Supervisor") { fleet.stopSupervisor() }
                } else {
                    Button("Start Supervisor") { fleet.startSupervisor() }
                }
                Divider()
                Button("Open Supervisor Log") { fleet.openSupervisorLog() }
                Button("Open Job Logs Folder") { fleet.openLogs() }
                Button("Refresh") { fleet.refresh() }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
            .disabled(fleet.busy)
        }
    }

    private func hostLine(_ c: FleetService.Capacity) -> some View {
        let gib = Double(1 << 30)
        let pressure = ["", "normal", "warning", "critical"]
        let p = c.Host.Pressure < pressure.count ? pressure[c.Host.Pressure] : "\(c.Host.Pressure)"
        return Text(String(format: "%d vCPU, %.0f GB in use · %.0f GB room · load %.1f · %@",
                           c.UsedCPUs, Double(c.UsedMemory) / gib, Double(c.RoomBytes) / gib, c.Host.Load5, p))
            .font(.caption2)
            .foregroundColor(.secondary)
            .lineLimit(1)
    }

    private func shapeRow(_ room: FleetService.ShapeRoom, running: Int) -> some View {
        HStack(spacing: 4) {
            Text(room.Shape.name)
                .font(.caption)
            Text("\(room.Shape.cpus) vCPU / \(room.Shape.memoryGB) GB")
                .font(.caption2)
                .foregroundColor(.secondary)
            Spacer(minLength: 0)
            Text("\(running) running · \(room.Fits) more fit")
                .font(.caption2)
                .foregroundColor(room.Fits == 0 ? .orange : .secondary)
        }
        .help(room.Reason)
    }
}
