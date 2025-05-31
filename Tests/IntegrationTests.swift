// © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.

import XCTest
import ChronoLock



class IntegrationTests: XCTestCase {
    func test_decrypt_deliversDecryptedMessageOnAlreadyEllapsedDate() throws {
        let timestamp = Date()
        let nonEllapsedDate = timestamp.adding(seconds: 10)
        let pastSUT = makeSUT(currentDate: {timestamp})
        let encrypted = try pastSUT.encrypt("any message to encrypt", until: nonEllapsedDate)
        
        let futureSUT = makeSUT(currentDate: {nonEllapsedDate})
        let decryptedMessage = try futureSUT.decrypt(encrypted)
        XCTAssertEqual(decryptedMessage, "any message to encrypt")
    }

    func test_decrypt_failsOnInvalidData() throws {
        let sut = makeSUT()
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
        let pastSUT = makeSUT(currentDate: {timestamp})
        
        try pastSUT.encryptAndSave(
            file: inputURL,
            until: futureDate,
            outputURL: outputURL
        )
        
        let futureSUT = makeSUT(currentDate: {futureDate})
        
        let decryptedURL = makeTemporaryAleatoryURL()
        try futureSUT.decryptAndSave(file: outputURL, at: decryptedURL)
        let decrypted = try String(data: Data(contentsOf: decryptedURL), encoding: .utf8)
        XCTAssertEqual(decrypted, content)
    }
}

private extension IntegrationTests {
    
    func makeSUT(currentDate: @escaping () -> Date = Date.init) -> ChronoLock {
        ChronoLock(
            encryptor: Encryptor(passphrase: "any passphrase"),
            decryptor: Encryptor(passphrase: "any passphrase"),
            reader: FileManager.default,
            persister: FileManager.default,
            currentDate: currentDate
        )
    }
    
    func makeTemporaryAleatoryURL() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    }
}
