import XCTest
import PlexSwift

final class PlexSwiftTests: XCTestCase {

    func testPinRequest() {
        let plex = Plex()
        let pinRequest = try! plex.signIn().waitFirst()
        XCTAssertNotNil(pinRequest)
        guard case .inviteCode(let code) = pinRequest else {
            XCTFail()
            return
        }

        XCTAssertEqual(code.count, 4)
    }

    static var allTests = [
        ("testPinRequest", testPinRequest),
    ]
}
