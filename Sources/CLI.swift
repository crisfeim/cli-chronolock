// © 2025  Cristian Felipe Patiño Rojas. Created on 31/5/25.

import ArgumentParser
import Foundation


@main
public struct ChronoLockCLI: ParsableCommand {
    @Option(name: .shortAndLong, help: "Path to input file to encrypt")
    var input: String?
    
    @Option(name: .shortAndLong, help: "Path to output file")
    var output: String?
    
    @Option(name: .shortAndLong, help: "Unlock date (ISO8601)")
    var unlockDate: String?
    
    @Option(name: .shortAndLong, help: "Decrypt mode")
    var mode: Mode?
    
    public var config: Config?
    public init() {}
    
    public struct NonEllapsedDateError: Error {
       public let message: String
    }
    
    public mutating func run() throws {
        let system = Self.makeChronoLock(passphrase: "some really long passphrase", currentDate: config?.currentDate ?? Date.init)
        
        guard let output else {
            throw ValidationError("Missing output path")
        }
        
        guard let input else {
            throw ValidationError("Missing input file for decryption")
        }
        
        switch mode {
        case .decrypt:  try handleDecryption(with: system, i: input, o: output)
        case .encrypt:  try handleEncryption(with: system, i: input, o: output)
        case .none: throw ValidationError("Missing mode. Mode needs to be specified")
        }
    }
}

// MARK: - Helpers
public enum DateParser {
    public static func parse(_ string: String) throws -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Europe/Madrid") ?? .current

        guard let date = formatter.date(from: string) else {
            throw ValidationError("Invalid date format. Use yyyy-MM-dd")
        }

        let calendar = Calendar(identifier: .gregorian)
        var components = calendar.dateComponents(in: formatter.timeZone!, from: date)
        components.hour = 12
        components.minute = 0
        components.second = 0

        return calendar.date(from: components)!
    }
    
    public static func timeIntervalAsString( _ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%02dd %02dh %02dm %02ds", days, hours, minutes, seconds)
    }

    private static func calendarMiddayReference() -> Date {
        var components = DateComponents()
        components.hour = 12
        components.minute = 0
        components.second = 0
        return Calendar(identifier: .gregorian).date(from: components) ?? Date()
    }
}

extension String {
    public static func unreachedDate(_ remaining: String) -> String {
        "Unlock date non reached. Remaining \(remaining)"
    }
}
private extension ChronoLockCLI {
    
    func handleDecryption(with system: ChronoLock, i inputPath: String, o outputPath: String) throws {
        do {
            try system.decryptAndSave(
                file: URL(fileURLWithPath: inputPath),
                at: URL(fileURLWithPath: outputPath)
            )
            print("🔓 Decrypted to \(outputPath)")
        } catch  {
            switch (error as? ChronoLock.Error) {
            case .nonEllapsedDate(let timeInterval):
                let formatted = DateParser.timeIntervalAsString(timeInterval)
                throw NonEllapsedDateError(message: formatted)
            default: throw ValidationError("Decryption error")
            }
        }
    }
    
    func handleEncryption(with system: ChronoLock, i inputPath: String, o outputPath: String) throws {
        guard let unlockDate else {
            throw ValidationError("Missing unlock date")
        }
        let date = try DateParser.parse(unlockDate)
        try system.encryptAndSave(
            file: URL(fileURLWithPath: inputPath),
            until: date,
            outputURL: URL(fileURLWithPath: outputPath)
        )
        print("🔒 Encrypted until \(date) at \(outputPath)")
    }

    static func makeChronoLock(passphrase: String, currentDate: @escaping () -> Date) -> ChronoLock {
        ChronoLock(
            encryptor: Encryptor(passphrase: passphrase),
            decryptor: Encryptor(passphrase: passphrase),
            reader: FileManager.default,
            persister: FileManager.default,
            currentDate: currentDate
        )
    }
}

extension ChronoLockCLI {
    enum Mode: String, ExpressibleByArgument, Decodable {
        case decrypt
        case encrypt
        init?(argument: String) {
            self.init(rawValue: argument)
        }
    }
    
    public struct Config {
        var currentDate: (() -> Date)?
        public init(currentDate: (() -> Date)? = nil) {self.currentDate = currentDate}
    }
}


extension ChronoLockCLI.Config: Decodable {
    public init(from decoder: any Decoder) throws {
        self = Self()
    }
    
}
