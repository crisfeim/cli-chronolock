// © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.

import CryptoKit
import Foundation

public struct Encryptor {
    private let passphrase: String
    
    public init(passphrase: String) {
        self.passphrase = passphrase
    }
    
    private var key: SymmetricKey {
        let keyData = SHA256.hash(data: Data(passphrase.utf8))
        return SymmetricKey(data: keyData)
    }

    public func encrypt<T: Encodable>(_ codableObject: T) throws -> Data {
        let encoded = try JSONEncoder().encode(codableObject)
        let sealedBox = try AES.GCM.seal(encoded, using: key)
        guard let combined = sealedBox.combined else {
            throw CombinedEncodingError()
        }
        return combined
    }
    
    struct CombinedEncodingError: Error {}
    
    public func decrypt<T: Decodable>(_ data: Data) throws -> T {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        let data = try AES.GCM.open(sealedBox, using: key)
        let decoded = try JSONDecoder().decode(T.self, from: data)
        return decoded
    }
}
