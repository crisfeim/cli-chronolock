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
        func read(_ fileURL: URL) throws -> String
    }
    
    public protocol Persister {
        func save(_ data: Data, at outputURL: URL) throws
    }
    
    public struct AlreadyEllapsedDateError: Error {}
    public struct NonEllapsedDateError: Error {}
    
    let encryptor: Encryptor
    let decryptor: Decryptor
    public let reader: Reader
    public let persister: Persister
    let currentDate: () -> Date
    
    public init(encryptor: Encryptor, decryptor: Decryptor, reader: Reader, persister: Persister, currentDate: @escaping () -> Date) {
        self.encryptor = encryptor
        self.decryptor = decryptor
        self.reader = reader
        self.persister = persister
        self.currentDate = currentDate
    }
    
   public func encrypt(_ content: String, until date: Date) throws -> Data {
        guard date > Date() else { throw AlreadyEllapsedDateError()}
        let item = Item(unlockDate: date, content: content)
        return try encryptor.encrypt(item)
    }
    
    public func decrypt(_ data: Data) throws -> String {
        let decrypted: Item = try decryptor.decrypt(data)
        guard decrypted.unlockDate <= currentDate() else {
            throw NonEllapsedDateError()
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
