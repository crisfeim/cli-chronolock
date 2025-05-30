// © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.

import XCTest
import CryptoKit

class EncryptorTests: XCTestCase {
    
    struct Encryptor {
        let passphrase: String
        
        private var key: SymmetricKey {
            let keyData = SHA256.hash(data: Data(passphrase.utf8))
            return SymmetricKey(data: keyData)
        }

        func encrypt<T: Codable>(_ codableObject: T) throws -> Data {
            let encoded = try JSONEncoder().encode(codableObject)
            let sealedBox = try AES.GCM.seal(encoded, using: key)
            guard let combined = sealedBox.combined else {
                throw CombinedEncodingError()
            }
            return combined
        }
        
        struct CombinedEncodingError: Error {}
        
        func decrypt<T: Codable>(_ data: Data) throws -> T {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let data = try AES.GCM.open(sealedBox, using: key)
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        }
    }
    
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
