// © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.

import XCTest
import CryptoKit

class ChronoLockTests: XCTestCase {
    
    struct Encryptor {
        let passphrase: String
        
        private var key: SymmetricKey {
            let keyData = SHA256.hash(data: Data(passphrase.utf8))
            return SymmetricKey(data: keyData)
        }

        func encrypt(_ message: String) throws -> Data {
            let messageData = message.data(using: .utf8)!
            let sealedBox = try AES.GCM.seal(messageData, using: key)
            return sealedBox.combined!
        }

        func decrypt(_ data: Data) throws -> String {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return String(data: decryptedData, encoding: .utf8)!
        }
    }
    
    func test_encryptAndDecrypt_withSamePassphrase_returnsOriginalMessage() throws {
        let sut = Encryptor(passphrase: "test phrase")
        let encrypted = try sut.encrypt("hello world")
        let decrypted = try sut.decrypt(encrypted)
        XCTAssertEqual(decrypted, "hello world")
    }
    
    func test_encryptAndDecrypt_withDifferentInstancesAndSamePassphrase_returnsOriginalMessage() throws {
        let passphrase = "test phrase"
        let sut1 = Encryptor(passphrase: passphrase)
        let sut2 = Encryptor(passphrase: passphrase)
        let encrypted = try sut1.encrypt("hello world")
        let decrypted = try sut2.decrypt(encrypted)
        XCTAssertEqual(decrypted, "hello world")
    }
    
    func test_encryptAndDecrypt_withDifferentInstancesAndDifferentPassPhrase_failsDecryption() throws {
        let sut1 = Encryptor(passphrase: "test phrase 1")
        let sut2 = Encryptor(passphrase: "test phrase 2 any freaking passphrase")
        let encrypted = try sut1.encrypt("hello world")
        XCTAssertThrowsError(try sut2.decrypt(encrypted))
    }
}
