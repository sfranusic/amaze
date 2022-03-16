//  Created by Sam Franusic on 3/11/22.

@testable import paso
import XCTest

class HealthKitControllerTests: XCTestCase {
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
}
