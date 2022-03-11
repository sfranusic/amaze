//
//  Created by Sam Franusic on 2/4/22.
//

import XCTest
@testable import paso

class pasoTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLaunchPerformance() throws {
        // This is an example of a performance test case.
        self.measure {
            XCUIApplication().launch()
        }
    }

}
