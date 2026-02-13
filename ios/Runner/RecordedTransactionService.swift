struct RecordedTransactionService {
    static let groupId = "group.mn.flow.flow"
    static let fileName = "recorded_transactions.jsonl"

    static func append(_ tx: RecordedTransaction) throws {
        let fm = FileManager.default
        let url = fm
            .containerURL(forSecurityApplicationGroupIdentifier: groupId)!
            .appendingPathComponent(fileName)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .withoutEscapingSlashes

        let data = try encoder.encode(tx)
        let line = data + Data([0x0A]) // newline

        if fm.fileExists(atPath: url.path) {
            let handle = try FileHandle(forWritingTo: url)
            try handle.seekToEnd()
            try handle.write(contentsOf: line)
            try handle.close()
        } else {
            try line.write(to: url)
        }
    }
}
