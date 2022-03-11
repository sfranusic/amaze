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

    func testFailureToGetStepsTriggersAlert() async throws {
        let healthKitController = HealthKitController()
        do {
            // Property 'shouldAlert' is false by default.
            XCTAssert(healthKitController.shouldAlert == false,
                      "Controller's alert property should be false by default.")
            // Without user interaction the permissions will not be changed,
            // and the call to update the step count will fail as a result.
            try await healthKitController.authorizeHealthKit()
            try await healthKitController.updatePublishedStepCount()
            XCTAssert(healthKitController.shouldAlert == true,
                      "Controller's alert property should be true if step count is not read.")
        } catch {
            XCTFail()
        }
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
