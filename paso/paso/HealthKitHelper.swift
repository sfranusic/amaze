//  Created by Sam Franusic on 2/2/22.

import HealthKit
import HealthKitUI
import SwiftUI

@MainActor
class HealthKitHelper: ObservableObject {

    public static let shared: HealthKitHelper = HealthKitHelper()
    public let healthStore: HKHealthStore

    @Published private(set) var stepCount: Int = 0

    init() {
        self.healthStore = HKHealthStore()
    }

    var stepData: HKQuantityType {
        guard let stepData = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            fatalError("*** creating step count HKQuantityType should never fail.")
        }
        return stepData
    }

    public var healthKitIsAuthorized: Bool {
        healthStore.authorizationStatus(for: stepData) == .sharingAuthorized
    }

    public func authorizeHealthKit() {
        guard HKHealthStore.isHealthDataAvailable() else {
            fatalError("Health store is unavailable.")
        }

        guard healthKitIsAuthorized else {
            return
        }

        let allData = Set([stepData])
        healthStore.requestAuthorization(toShare: nil, read: allData, completion: { (_, error) in

            if let error = error {
                print(error)
            }
        })

    }

    func getTodaysStepCount(completion: @escaping (Double) -> Void) {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: stepData,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }

        healthStore.execute(query)
    }

    public func getStepCount() {
        self.getTodaysStepCount { count in
            DispatchQueue.main.async {
                HealthKitHelper.shared.stepCount = Int(count)
            }
        }

    }
}
