// © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.

import XCTest
import ChronoLock

class ChronoLockTests: XCTestCase {
    
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
}
