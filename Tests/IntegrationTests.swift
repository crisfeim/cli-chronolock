// © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.

import XCTest
import ChronoLock



extension ChronoLockTests {
    func test_decrypt_deliversDecryptedMessageOnAlreadyEllapsedDate() throws {
        let timestamp = Date()
        let nonEllapsedDate = timestamp.adding(seconds: 10)
        let encryptor = Encryptor(passphrase: "passphrase")
        let sut = ChronoLock(encryptor: encryptor, decryptor: encryptor, reader: ReaderDummy(), persister: PersisterDummy(), currentDate: {timestamp})
        let encrypted = try sut.encrypt("any message to encrypt", until: nonEllapsedDate)
        
        let ellapsedDate = nonEllapsedDate
        let sut2 = ChronoLock(encryptor: encryptor, decryptor: encryptor, reader: ReaderDummy(), persister: PersisterDummy(), currentDate: {ellapsedDate})
        let decryptedMessage = try sut2.decrypt(encrypted)
        XCTAssertEqual(decryptedMessage, "any message to encrypt")
    }
    
    func test_decrypt_failsOnInvalidData() throws {
        let encryptor = Encryptor(passphrase: "passphrase")
        let sut = ChronoLock(encryptor: encryptor, decryptor: encryptor, reader: ReaderDummy(), persister: PersisterDummy(), currentDate: Date.init)
        let invalidData = Data()
        XCTAssertThrowsError(try sut.decrypt(invalidData))
    }
    
    func test_encryptAndSave_thenDecryptAndSave_restoresOriginalFileContent() throws {
       
        let inputURL = makeTemporaryAleatoryURL()
        let content = "some password"
        try content.write(to: inputURL, atomically: true, encoding: .utf8)
        
        let outputURL = makeTemporaryAleatoryURL()
        
        let timestamp = Date()
        let futureDate = timestamp.adding(seconds: 60)
        let encryptor = Encryptor(passphrase: "passphrase")
        let pastSUT = ChronoLock(
            encryptor: encryptor,
            decryptor: encryptor,
            reader: FileManager.default,
            persister: FileManager.default,
            currentDate: {timestamp}
        )
        
        try pastSUT.encryptAndSave(
            file: inputURL,
            until: futureDate,
            outputURL: outputURL
        )
        
        let futureSUT = ChronoLock(
            encryptor: encryptor,
            decryptor: encryptor,
            reader: FileManager.default,
            persister: FileManager.default,
            currentDate: {futureDate})
        
        let decryptedURL = makeTemporaryAleatoryURL()
        try futureSUT.decryptAndSave(file: outputURL, at: decryptedURL)
        let decrypted = try String(data: Data(contentsOf: decryptedURL), encoding: .utf8)
        XCTAssertEqual(decrypted, content)
    }
    
    func testPasswordTxtFileURL() -> URL {
          Bundle.module.bundleURL
            .appendingPathComponent("Contents/Resources")
            .appendingPathComponent("test_files")
            .appendingPathComponent("password.txt")
      }
    
    func makeTemporaryAleatoryURL() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    }
}
