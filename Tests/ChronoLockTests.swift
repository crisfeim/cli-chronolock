// © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.

import XCTest
import ChronoLock

class ChronoLockTests: XCTestCase {
    struct ChronoLock {
        protocol Encryptor {
            func encrypt<T: Codable>(_ codableObject: T) throws -> Data
        }
        
        struct AlreadyEllapsedDateError: Error {}
        
        let encryptor: Encryptor
        let currentDate: () -> Date
        
        func encrypt(_ content: String, until date: Date) throws -> Data {
            guard date > Date() else { throw AlreadyEllapsedDateError()}
            return try encryptor.encrypt(content)
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
        let sut = ChronoLock(encryptor: encryptor, currentDate: { Date() })
        
        XCTAssertThrowsError(try sut.encrypt("any message", until: Date()))
    }
    
    func test_encrypt_deliversErrorOnAlreadyEllapsedDate() throws {
        
        let timestamp = Date()
        let alreadyElapsedDate = timestamp.adding(seconds: -1)
        
        let encryptor = EncryptorDummy()
        let sut = ChronoLock(encryptor: encryptor, currentDate: {timestamp})
        
        XCTAssertThrowsError(try sut.encrypt("any message", until: alreadyElapsedDate)) { error in
            XCTAssertTrue(error is ChronoLock.AlreadyEllapsedDateError)
        }
    }
    
    func test_encrypt_deliversNoErrorOnNonEllapsedDateAndEncryptorSuccess() throws {
        
        let timestamp = Date()
        let nonEllapsedDate = timestamp.adding(seconds: 1)
         
        let encryptor = EncryptorDummy()
        let sut = ChronoLock(encryptor: encryptor, currentDate: {timestamp})
        
        XCTAssertNoThrow(try sut.encrypt("any message", until: nonEllapsedDate))
    }
}

// MARK: - Helpers
private extension ChronoLockTests {
    struct EncryptorDummy: ChronoLock.Encryptor {
        func encrypt<T: Codable>(_ codableObject: T) throws -> Data {
            Data()
        }
    }
    
    func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
}

private extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
