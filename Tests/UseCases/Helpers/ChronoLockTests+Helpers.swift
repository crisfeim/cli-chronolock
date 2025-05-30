// © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.

import Foundation
import ChronoLock

// MARK: - Doubles
// Dummies
extension ChronoLockTests {
    struct EncryptorDummy: ChronoLock.Encryptor {
        func encrypt<T: Codable>(_ codableObject: T) throws -> Data {
            Data()
        }
    }
    
    
    struct DecryptorDummy: ChronoLock.Decryptor {
        func decrypt<T: Decodable>(_ data: Data) throws -> T {
            return ChronoLock.Item(unlockDate: Date(), content: "any content") as! T
        }
    }
    
    struct ReaderDummy: ChronoLock.Reader {
        func read(_ fileURL: URL) throws -> String {""}
    }
    
    struct PersisterDummy: ChronoLock.Persister {
        func save(_ data: Data, at outputURL: URL) throws {}
    }
}

// MARK: - Factories
extension ChronoLockTests {
    func makeSUT(
        encryptor: ChronoLock.Encryptor = EncryptorDummy(),
        decryptor: ChronoLock.Decryptor = DecryptorDummy(),
        reader: ChronoLock.Reader = ReaderDummy(),
        persister: ChronoLock.Persister = PersisterDummy(),
        currentDate: @escaping () -> Date = Date.init
    ) -> ChronoLock {
        ChronoLock(encryptor: encryptor, decryptor: decryptor, reader: reader, persister: persister, currentDate: currentDate)
    }
    
    func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    func anyDate() -> Date {
        Date()
    } 
}
