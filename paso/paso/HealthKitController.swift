//  Created by Sam Franusic on 2/24/22.

import HealthKit
import SwiftUI

actor HealthKitController: ObservableObject {

    public let healthStore: HKHealthStore
    @Published private(set) var stepCount: Int = 0

    var stepData: HKQuantityType {
        guard let stepData = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            fatalError("*** creating step count HKQuantityType should never fail.")
        }
        return stepData
    }

    public var healthKitIsAuthorized: Bool {
        healthStore.authorizationStatus(for: stepData) == .sharingAuthorized
    }

    init() {
        self.healthStore = HKHealthStore()
    }

    public func authorizeHealthKit() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            fatalError("Health store is unavailable.")
        }

        guard healthKitIsAuthorized else {
            return
        }
        
        let allData = Set([stepData])

        do {
            try await healthStore.requestAuthorization(toShare: allData, read: Set())

        } catch {
            print("Request for authorization to share data failed.")
        }

    }
}
