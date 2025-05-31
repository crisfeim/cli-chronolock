// © 2025  Cristian Felipe Patiño Rojas. Created on 31/5/25.
import XCTest
import ChronoLock

class CLITests: XCTestCase {
    func test_cliEncryptsAndDecryptsSucceeds_onEllapsedDate() throws {
        
        let inputURL = uniqueTemporaryURL()
        try "some secret content".write(to: inputURL, atomically: true, encoding: .utf8)

        let outputURL = uniqueTemporaryURL()
        let futureDate = "2025-06-01"

        var pastCLI = try ChronoLockCLI.parse([
            "--input", inputURL.path,
            "--output", outputURL.path,
            "--mode", "encrypt",
            "--unlock-date", futureDate
        ])
        
        pastCLI.config = ChronoLockCLI.Config(currentDate: { fixedNow() })
        try pastCLI.run()
        
        
        let decryptedURL = uniqueTemporaryURL()
        var futureCLI = try ChronoLockCLI.parse([
            "--input", outputURL.path,
            "--output", decryptedURL.path,
            "--mode", "decrypt"
        ])
        
        futureCLI.config = ChronoLockCLI.Config(currentDate: { try! DateParser.parse(futureDate) })
        try futureCLI.run()

        XCTAssertEqual(try String(data: Data(contentsOf: decryptedURL), encoding: .utf8), "some secret content")
    }
    
    func test_cliEncryptsAndDecryptsFailsReturningCorrectFormattedTimeInterval_onNonEllapsedUnlockDate() throws {
        
        let inputURL = uniqueTemporaryURL()
        try "some secret content".write(to: inputURL, atomically: true, encoding: .utf8)

        let outputURL = uniqueTemporaryURL()
        let futureDate = "2025-06-01"

        var sut = try ChronoLockCLI.parse([
            "--input", inputURL.path,
            "--output", outputURL.path,
            "--mode", "encrypt",
            "--unlock-date", futureDate
        ])
        
        sut.config = ChronoLockCLI.Config(currentDate: { fixedNow() })
        try sut.run()
        
        
        let decryptedURL = uniqueTemporaryURL()
        sut = try ChronoLockCLI.parse([
            "--input", outputURL.path,
            "--output", decryptedURL.path,
            "--mode", "decrypt"
        ])
        sut.config = ChronoLockCLI.Config(currentDate: { fixedNow() })
        
        XCTAssertThrowsError(try sut.run()) { error in
            
            XCTAssertEqual((error as? ChronoLockCLI.NonEllapsedDateError)?.message, "01d 00h 00m 00s")
        }
    }
    
    func uniqueTemporaryURL() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    }
}

private func fixedNow() -> Date {
    Calendar(identifier: .gregorian).date(from: DateComponents(
        timeZone: TimeZone(identifier: "Europe/Madrid"),
        year: 2025,
        month: 5,
        day: 31,
        hour: 12,
        minute: 0
    ))!
}

private extension Date {
    private func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}
