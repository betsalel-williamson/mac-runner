import XCTest
@testable import MacRunner

/// The Fleet section reads `mbp-supervisor capacity -json`; these pin that format.
final class FleetServiceTests: XCTestCase {

    func testDecodesSupervisorCapacityJSON() throws {
        let json = """
        {
          "Host": {"AvailableBytes": 66426765312, "Pressure": 1, "Load5": 4.44},
          "UsedMemory": 0, "UsedCPUs": 0, "PendingBytes": 0, "RoomBytes": 49246896128,
          "Shapes": [
            {"Shape": {"name": "mbp-small", "labels": ["mbp-small"], "cpus": 2, "memoryGB": 4, "diskGB": 80},
             "Fits": 7, "Reason": "vCPU budget: 0 of 14 used"}
          ]
        }
        """
        let capacity = try JSONDecoder().decode(FleetService.Capacity.self, from: Data(json.utf8))
        XCTAssertEqual(capacity.Host.Pressure, 1)
        XCTAssertEqual(capacity.Shapes.first?.Shape.name, "mbp-small")
        XCTAssertEqual(capacity.Shapes.first?.Fits, 7)
    }

    func testJobShapeComesFromContainerName() {
        XCTAssertEqual(FleetService.Job(name: "mbp-job-small-f874a242", cpus: 2, memoryBytes: 0).shape, "mbp-small")
        XCTAssertEqual(FleetService.Job(name: "mbp-job-large-0a1b2c3d", cpus: 6, memoryBytes: 0).shape, "mbp-large")
    }
}
