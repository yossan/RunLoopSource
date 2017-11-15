import XCTest
@testable import RunLoopSource

class RunLoopSourceTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(RunLoopSource().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
