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
}

// MARK: - Factories
extension ChronoLockTests {
    func makeSUT(encryptor: ChronoLock.Encryptor = EncryptorDummy(), decryptor: ChronoLock.Decryptor = DecryptorDummy(), currentDate: @escaping () -> Date = Date.init) -> ChronoLock {
       ChronoLock(encryptor: encryptor, decryptor: decryptor, currentDate: currentDate)
    }
    
    func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
}
