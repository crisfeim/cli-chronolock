// © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.

import XCTest
import ChronoLock

extension ChronoLock {
    func encryptAndSave(file inputURL: URL, until date: Date, outputURL: URL) throws {
        let _ = try reader.read(inputURL)
        try persister.save(Data(), at: outputURL)
    }
}
extension ChronoLockTests {
    func test_encryptAndSave_deliversErrorOnReadError() throws {
        struct ReaderStub: ChronoLock.Reader {
            let error: Error
            func read(_ fileURL: URL) throws -> String {
                throw error
            }
        }
        let reader = ReaderStub(error: anyError())
        let sut = ChronoLock(encryptor: EncryptorDummy(), decryptor: DecryptorDummy(), reader: reader, persister: PersisterDummy(), currentDate: Date.init)
        let anyInputURL = URL(string: "file:///anyinput-url.txt")!
        let anyOutputURL = URL(string: "file:///anyoutput-url.txt")!
        XCTAssertThrowsError(try sut.encryptAndSave(file: anyInputURL, until: anyDate(), outputURL: anyOutputURL))
    }
    
    func test_encryptAndSave_deliversErrorOnSaveError() throws {
        struct PersisterStub: ChronoLock.Persister {
            let error: Error
            func save(_ data: Data, at outputURL: URL) throws {
                throw error
            }
        }
      
        let persister = PersisterStub(error: anyError())
        let sut = ChronoLock(
            encryptor: EncryptorDummy(),
            decryptor: DecryptorDummy(),
            reader: ReaderDummy(),
            persister: persister,
            currentDate: Date.init
        )
        let anyInputURL = URL(string: "file:///anyinput-url.txt")!
        let anyOutputURL = URL(string: "file:///anyoutput-url.txt")!
        XCTAssertThrowsError(try sut.encryptAndSave(file: anyInputURL, until: anyDate(), outputURL: anyOutputURL))
    }
}
