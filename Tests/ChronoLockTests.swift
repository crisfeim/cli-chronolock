// © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.

import XCTest
import ChronoLock

class ChronoLockTests: XCTestCase {
    struct ChronoLock {
        protocol Encryptor {
            func encrypt<T: Codable>(_ codableObject: T) throws -> Data
        }
        
        protocol Decryptor {
            func decrypt<T: Codable>(_ data: Data) throws -> T
        }
        
        struct AlreadyEllapsedDateError: Error {}
        
        let encryptor: Encryptor
        let decryptor: Decryptor
        let currentDate: () -> Date
        
        func encrypt(_ content: String, until date: Date) throws -> Data {
            guard date > Date() else { throw AlreadyEllapsedDateError()}
            return try encryptor.encrypt(content)
        }
        
        func decrypt(_ data: Data) throws -> String {
            try decryptor.decrypt(data)
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
        let sut = makeSUT(encryptor: encryptor)
        
        XCTAssertThrowsError(try sut.encrypt("any message", until: anyDate()))
    }
    
    func test_encrypt_deliversErrorOnAlreadyEllapsedDate() throws {
        
        let timestamp = Date()
        let alreadyEllapsedDate = timestamp.adding(seconds: -1)
        
        let sut = makeSUT(currentDate: {timestamp})
        
        XCTAssertThrowsError(try sut.encrypt("any message", until: alreadyEllapsedDate)) { error in
            XCTAssertTrue(error is ChronoLock.AlreadyEllapsedDateError)
        }
    }
    
    func test_encrypt_deliversNoErrorOnNonEllapsedDateAndEncryptorSuccess() throws {
        
        let timestamp = Date()
        let nonEllapsedDate = timestamp.adding(seconds: 1)
         
        let sut = makeSUT(currentDate: {timestamp})
        
        XCTAssertNoThrow(try sut.encrypt("any message", until: nonEllapsedDate))
    }
    
    func test_decrypt_deliversErrorOnDecryptorError() throws {
        
        struct DecryptorStub: ChronoLock.Decryptor {
            let error: Error
            func decrypt<T: Codable>(_ data: Data) throws -> T {
               throw error
            }
        }
        
        let decryptor = DecryptorStub(error: anyError())
        
        let sut = makeSUT(decryptor: decryptor)
        let anyEncryptedData = Data()
        XCTAssertThrowsError(try sut.decrypt(anyEncryptedData))
    }
}

// MARK: - Helpers
private extension ChronoLockTests {
    
    func makeSUT(encryptor: ChronoLock.Encryptor = EncryptorDummy(), decryptor: ChronoLock.Decryptor = DecryptorDummy(), currentDate: @escaping () -> Date = Date.init) -> ChronoLock {
       ChronoLock(encryptor: encryptor, decryptor: decryptor, currentDate: currentDate)
    }
    
    struct EncryptorDummy: ChronoLock.Encryptor {
        func encrypt<T: Codable>(_ codableObject: T) throws -> Data {
            Data()
        }
    }
    
    struct DecryptorDummy: ChronoLock.Decryptor {
        
        func decrypt<T: Codable>(_ data: Data) throws -> T {
           return "any result" as! T
        }
    }
    
    func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    func anyDate() -> Date {
        Date()
    }
}

private extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
