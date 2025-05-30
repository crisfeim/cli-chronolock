// © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.

import XCTest
import ChronoLock

extension Encryptor: ChronoLock.Encryptor {}
extension Encryptor: ChronoLock.Decryptor {}

class IntegrationTests: XCTestCase {
    
    func test_decrypt_deliversDecryptedMessageOnAlreadyEllapsedDate() throws {
        let timestamp = Date()
        let nonEllapsedDate = timestamp.adding(seconds: 10)
        let encryptor = Encryptor(passphrase: "passphrase")
        let sut = ChronoLock(encryptor: encryptor, decryptor: encryptor, currentDate: {timestamp})
        let encrypted = try sut.encrypt("any message to encrypt", until: nonEllapsedDate)
        
        let ellapsedDate = nonEllapsedDate
        let sut2 = ChronoLock(encryptor: encryptor, decryptor: encryptor, currentDate: {ellapsedDate})
        let decryptedMessage = try sut2.decrypt(encrypted)
        XCTAssertEqual(decryptedMessage, "any message to encrypt")
    }
    
    func test_decrypt_failsOnInvalidData() throws {
        let encryptor = Encryptor(passphrase: "passphrase")
        let sut = ChronoLock(encryptor: encryptor, decryptor: encryptor, currentDate: Date.init)
        let invalidData = Data()
        XCTAssertThrowsError(try sut.decrypt(invalidData))
    }
}
