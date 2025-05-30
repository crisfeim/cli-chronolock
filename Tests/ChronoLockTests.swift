// © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.

import XCTest
import ChronoLock

class ChronoLockTests: XCTestCase {
    struct ChronoLock {
        protocol Encryptor {
            func encrypt<T: Codable>(_ codableObject: T) throws -> Data
        }
        
        
        let encryptor: Encryptor
        func encrypt(_ content: String, until date: Date) throws -> Data {
            try encryptor.encrypt(content)
        }
    }
    
    func test_encrypt_deliversErrorOnEncryptorError() throws {
        struct EncryptorStub: ChronoLock.Encryptor {
            let error: Error
            func encrypt<T>(_ codableObject: T) throws -> Data where T : Decodable, T : Encodable {
                throw error
            }
        }
        let encryptor = EncryptorStub(error: anyError())
        let sut = ChronoLock(encryptor: encryptor)
        
        XCTAssertThrowsError(try sut.encrypt("any message", until: Date()))
    }
    
}

private extension ChronoLockTests {
    func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
}

