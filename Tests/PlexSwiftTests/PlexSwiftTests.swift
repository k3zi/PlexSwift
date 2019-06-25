import XCTest
@testable import PlexSwift

final class PlexSwiftTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(PlexSwift().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
