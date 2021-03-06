//  Created by Sam Franusic on 2/24/22.

import HealthKit
import SwiftUI

actor HealthKitController: ObservableObject {
    let healthStore: HKHealthStore
    @Published private(set) nonisolated var stepCount = 0
    @Published private(set) nonisolated var stepDataList: [StepRowData] = []
    @Published nonisolated var shouldAlert = false
    var healthKitIsAuthorized: Bool {
        healthStore.authorizationStatus(for: stepData) == .sharingAuthorized
    }
    private var stepData: HKQuantityType {
        guard let stepData = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            fatalError("*** creating step count HKQuantityType should never fail.")
        }
        return stepData
    }

    init() {
        self.healthStore = HKHealthStore()
    }

    func authorizeHealthKit() async throws {
        HKHealthStore.isHealthDataAvailable()

        let allData = Set([stepData])
        do {
            try await healthStore.requestAuthorization(toShare: Set(), read: allData)
        } catch {
            print("Request for authorization to share data failed.")
        }
    }

    @MainActor
    func updatePublishedStepCount() async throws {
        guard let result = try await queryHealthKitForStepCount(), let sum = result.sumQuantity() else {
            self.shouldAlert = true
            return
        }
        stepCount = Int(sum.doubleValue(for: HKUnit.count()))
        let newStepRow = StepRowData(steps: stepCount)
        if stepDataList.last != newStepRow {
            stepDataList.append(newStepRow)
        }
    }

    private func queryHealthKitForStepCount() async throws -> HKStatistics? {
        return try await withCheckedThrowingContinuation { continuation in
            // Create query for step count.
            let now = Date()
            let startOfDay = Calendar.current.startOfDay(for: now)
            let predicate = HKQuery.predicateForSamples(
                withStart: startOfDay,
                end: now,
                options: .strictStartDate)
            let query = HKStatisticsQuery(
                quantityType: stepData,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum) { _, result, error in

                    if let error = error {
                        print(error.localizedDescription)
                        continuation.resume(returning: nil)
                    } else {
                        continuation.resume(returning: result)
                    }
            }
            healthStore.execute(query)
        }
    }

    private func executeObserverQueryForStepCount() async throws {
        let observerQuery = HKObserverQuery(sampleType: stepData,
                                            predicate: nil) { _, _, _ in
            Task {
                try await self.updatePublishedStepCount()
            }
        }
        healthStore.execute(observerQuery)
    }

    @MainActor
    func setUpAccessToStepData() async throws {
        try await self.authorizeHealthKit()
        try await self.updatePublishedStepCount()
        try await self.executeObserverQueryForStepCount()
    }
}

extension HealthKitController {
    enum PasoHealthKitError: Error {
        case authentication, data
    }
}
