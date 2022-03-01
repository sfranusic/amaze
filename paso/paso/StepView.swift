//  StepView.swift
//  Created by Sam Franusic on 2/4/22.


import HealthKit
import SwiftUI

struct StepView: View {
    @StateObject var healthKitHelper = HealthKitController()
    var body: some View {
        Text("\(healthKitHelper.stepCount)")
            .foregroundColor(.red)
            .fontWeight(.semibold)

            .task {
                do {
                    try await healthKitHelper.authorizeHealthKit()
                    try await healthKitHelper.updatePublishedStepCount()
                } catch {

                }
            }
    }
}

struct StepView_Previews: PreviewProvider {
    static var previews: some View {
        StepView()
    }
}
