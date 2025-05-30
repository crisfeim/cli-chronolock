// © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.

import XCTest
import ChronoLock

class EncryptorTests: XCTestCase {

    
    func test_encryptAndDecrypt_withCodableObjectAndDifferentPassphrase_failsDecryption() throws {
    
        let itemToEncrypt = AnyCodableObject(message: "any message")
    
        let sut1 = Encryptor(passphrase: "passphrase 1")
        let sut2 = Encryptor(passphrase: "passphrase 2")
        
        let encrypted = try sut1.encrypt(itemToEncrypt)
        XCTAssertThrowsError(try {
            let d: AnyCodableObject = try sut2.decrypt(encrypted)
            return d
        }())
    }
    
    func test_encryptAndDecrypt_withCodableObjectAndSamePassphraseReturnsOriginalObject() throws {
        
        let itemToEncrypt = AnyCodableObject(message: "any message")
        let uniquePassPhraseAcrossInstances = "unique passphrase across instances"
        let sut1 = Encryptor(passphrase: uniquePassPhraseAcrossInstances)
        let sut2 = Encryptor(passphrase: uniquePassPhraseAcrossInstances)
        
        let encrypted = try sut1.encrypt(itemToEncrypt)
        let decrypted: AnyCodableObject = try sut2.decrypt(encrypted)
        
        XCTAssertEqual(decrypted, itemToEncrypt)
    }
}

private extension EncryptorTests {
    struct AnyCodableObject: Codable, Equatable {
        let message: String
    }
}
