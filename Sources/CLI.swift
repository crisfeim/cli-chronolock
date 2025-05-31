// © 2025  Cristian Felipe Patiño Rojas. Created on 31/5/25.

import ArgumentParser
import Foundation

@main
struct ChronoLockCLI: ParsableCommand {
    @Option(name: .shortAndLong, help: "Path to input file to encrypt")
    var input: String?
    
    @Option(name: .shortAndLong, help: "Path to output file")
    var output: String?
    
    @Option(name: .shortAndLong, help: "Unlock date (ISO8601)")
    var unlockDate: String?
    
    @Option(name: .shortAndLong, help: "Decrypt mode")
    var mode: Mode?
    
    mutating func run() throws {
        let system = makeChronoLock(passphrase: "some really long passphrase")
        
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
                throw ValidationError("Unlock date non reached. Remaining \(timeInterval)")
            default: throw ValidationError("Decryption error")
            }
        }
    }
    
    func handleEncryption(with system: ChronoLock, i inputPath: String, o outputPath: String) throws {
        guard let unlockDate else {
            throw ValidationError("Missing unlock date")
        }
        let date = try parseDate(unlockDate)
        try system.encryptAndSave(
            file: URL(fileURLWithPath: inputPath),
            until: date,
            outputURL: URL(fileURLWithPath: outputPath)
        )
        print("🔒 Encrypted until \(date) at \(outputPath)")
    }

    func parseDate(_ string: String) throws -> Date {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: string) else {
            throw ValidationError("Invalid date format. Use ISO8601.")
        }
        return date
    }

    func makeChronoLock(passphrase: String) -> ChronoLock {
        ChronoLock(
            encryptor: Encryptor(passphrase: passphrase),
            decryptor: Encryptor(passphrase: passphrase),
            reader: FileManager.default,
            persister: FileManager.default,
            currentDate: Date.init
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
}
