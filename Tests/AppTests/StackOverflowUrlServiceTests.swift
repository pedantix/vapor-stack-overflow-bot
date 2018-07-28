@testable import App
import XCTest

final class StackOverflowUrlServiceTests: XCTestCase {
    func testURLRepresentableDefaultTime() throws {
        let defaultTimeAgo  = Int(Date().addingTimeInterval(-300).timeIntervalSince1970)
        let tag = "50 dogs"
        let expectedUrl = "https://api.stackexchange.com/2.2/questions?order=desc&site=stackoverflow&sort=activity&tagged=\(tag)&fromdate=\(defaultTimeAgo)"

        let urlRep = StackOverflowUrlService().requestForQuestions(for: "50 dogs")


        XCTAssertEqual(expectedUrl, urlRep as? String)
    }

    func testURLRepresentableCustomTimeAgo() throws {
        let defaultTimeAgo  = Int(Date().addingTimeInterval(-600).timeIntervalSince1970)
        let tag = "50 dogs"
        let expectedUrl = "https://api.stackexchange.com/2.2/questions?order=desc&site=stackoverflow&sort=activity&tagged=\(tag)&fromdate=\(defaultTimeAgo)"

        let urlRep = StackOverflowUrlService().requestForQuestions(for: "50 dogs", timeAgo: 600)

        XCTAssertEqual(expectedUrl, urlRep as? String)
    }

    static let allTests = [
        ("testNothing", testURLRepresentableDefaultTime)
    ]
}
