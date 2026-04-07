import Foundation
import OSLog

struct AnalyticsEvent: Equatable {
    let name: String
    let payload: [String: String]
    let occurredAt: Date

    init(name: String, payload: [String: String] = [:], occurredAt: Date = Date()) {
        self.name = name
        self.payload = payload
        self.occurredAt = occurredAt
    }
}

protocol AnalyticsClient: AnyObject {
    func track(_ event: AnalyticsEvent)
}

final class LocalAnalyticsClient: AnalyticsClient {
    private struct Record: Encodable {
        let name: String
        let payload: [String: String]
        let occurredAt: String
    }

    private let logger = Logger(subsystem: "PerfectStack", category: "analytics")
    private let queue = DispatchQueue(label: "PerfectStack.analytics")
    private let fileURL: URL
    private let formatter = ISO8601DateFormatter()

    init(fileManager: FileManager = .default) {
        let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        let directory = supportDirectory.appendingPathComponent("PerfectStack", isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        fileURL = directory.appendingPathComponent("analytics.jsonl")
    }

    func track(_ event: AnalyticsEvent) {
        logger.info("\(event.name, privacy: .public) \(String(describing: event.payload), privacy: .public)")

        let record = Record(
            name: event.name,
            payload: event.payload,
            occurredAt: formatter.string(from: event.occurredAt)
        )

        queue.async { [fileURL] in
            guard let data = try? JSONEncoder().encode(record) else { return }
            let newline = Data([0x0A])

            if FileManager.default.fileExists(atPath: fileURL.path) {
                if let handle = try? FileHandle(forWritingTo: fileURL) {
                    defer { try? handle.close() }
                    try? handle.seekToEnd()
                    try? handle.write(contentsOf: data)
                    try? handle.write(contentsOf: newline)
                }
            } else {
                var output = data
                output.append(newline)
                try? output.write(to: fileURL, options: .atomic)
            }
        }
    }
}
