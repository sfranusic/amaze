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

    private func updatePublishedStepCount(with count: Int) async throws {

        guard let result = try await queryHealthKitForStepCount(), let sum = result.sumQuantity() else {
            return
        }
        let count = Int(sum.doubleValue(for: HKUnit.count()))
        stepCount = max(count, stepCount)
    }

    private func queryHealthKitForStepCount() async throws -> HKStatistics? {

        return try await withCheckedThrowingContinuation { continuation in
            // Create query for step count.
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
                options: .cumulativeSum) { _, result, error in

                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: result)
                    }
            }
            healthStore.execute(query)
        }
    }
}

extension HealthKitController {
    enum PasoHealthKitError: Error {
        case authentication, data
    }
}
