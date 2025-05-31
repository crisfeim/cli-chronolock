// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser

@main
struct ChronoLockCLI: ParsableCommand {
    mutating func run() throws {
        print("Hello, world!")
    }
}

import Foundation

public struct ChronoLock {
    public protocol Encryptor {
        func encrypt<T: Codable>(_ codableObject: T) throws -> Data
    }
    
    public protocol Decryptor {
        func decrypt<T: Decodable>(_ data: Data) throws -> T
    }
    
    public protocol Reader {
        func read(_ fileURL: URL) throws -> Data
    }
    
    public protocol Persister {
        func save(_ data: Data, at outputURL: URL) throws
        func save(_ content: String, at outputURL: URL) throws
    }
    
    public enum Error: Swift.Error, Equatable {
        case alreadyEllapsedDate
        case nonEllapsedDate(TimeInterval)
        case invalidData
    }
    
    let encryptor: Encryptor
    let decryptor: Decryptor
    let reader: Reader
    let persister: Persister
    let currentDate: () -> Date
    
    public init(encryptor: Encryptor, decryptor: Decryptor, reader: Reader, persister: Persister, currentDate: @escaping () -> Date) {
        self.encryptor = encryptor
        self.decryptor = decryptor
        self.reader = reader
        self.persister = persister
        self.currentDate = currentDate
    }
    
   public func encrypt(_ content: String, until date: Date) throws -> Data {
       guard date > currentDate() else { throw Error.alreadyEllapsedDate }
        let item = Item(unlockDate: date, content: content)
        return try encryptor.encrypt(item)
    }
    
    public func decrypt(_ data: Data) throws -> String {
        let decrypted: Item = try decryptor.decrypt(data)
        let now = currentDate()
        guard decrypted.unlockDate <= now else {
            let remaining = decrypted.unlockDate.timeIntervalSince(now)
            throw Error.nonEllapsedDate(remaining)
        }
        return decrypted.content
    }
    
    public struct Item: Codable {
        let unlockDate: Date
        let content: String
        
        public init(unlockDate: Date, content: String) {
            self.unlockDate = unlockDate
            self.content = content
        }
    }
}

// MARK: - I/O
// Infrastructure:
extension Encryptor: ChronoLock.Decryptor {}
extension Encryptor: ChronoLock.Encryptor {}

extension FileManager: ChronoLock.Reader {
    public func read(_ fileURL: URL) throws -> Data {
        try Data(contentsOf: fileURL)
    }
}

extension FileManager: ChronoLock.Persister {
    public func save(_ data: Data, at outputURL: URL) throws {
        try data.write(to: outputURL, options: .atomic)
    }
    
    public func save(_ content: String, at outputURL: URL) throws {
        try content.write(to: outputURL, atomically: true, encoding: .utf8)
    }
}

// Coordinator logic:
extension ChronoLock {
   public func encryptAndSave(file inputURL: URL, until date: Date, outputURL: URL) throws {
        let data = try reader.read(inputURL)
        guard let content = String(data: data, encoding: .utf8) else {
            throw Error.invalidData
        }
        let encrypted = try encrypt(content, until: date)
        try persister.save(encrypted, at: outputURL)
    }
}

extension ChronoLock {
    public func decryptAndSave(file fileURL: URL, at outputURL: URL) throws {
        let data = try reader.read(fileURL)
        let decrypted = try decrypt(data)
        try persister.save(decrypted, at: outputURL)
        
    }
}

