// © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.

import ChronoLock
import Foundation
import XCTest


extension ChronoLockTests {
    
    func test_decrypt_deliversErrorOnDecryptorError() throws {
        
        struct DecryptorStub: ChronoLock.Decryptor {
            let error: Error
            func decrypt<T: Decodable>(_ data: Data) throws -> T {
               throw error
            }
        }
        
        let decryptor = DecryptorStub(error: anyError())
        
        let sut = makeSUT(decryptor: decryptor)
        let anyEncryptedData = Data()
        XCTAssertThrowsError(try sut.decrypt(anyEncryptedData))
    }

    
    func test_decrypt_deliversErrorOnNonEllapsedDate() throws {
        let timestamp = Date()
        let nonEllapsedDate = timestamp.adding(seconds: 1)
        let sut = makeSUT(currentDate: { timestamp })
        let encrypted = try sut.encrypt("any message to encrypt", until: nonEllapsedDate)
        XCTAssertThrowsError(try sut.decrypt(encrypted)) { error in
            XCTAssertTrue(error is ChronoLock.NonEllapsedDateError)
        }
    }
}
