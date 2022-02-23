//  StepView.swift
//  Created by Sam Franusic on 2/4/22.


import HealthKit
import SwiftUI

struct StepView: View {
    @StateObject var healthKitHelper = HealthKitHelper.shared
    var body: some View {
            VStack {
                Text("Steps: \(healthKitHelper.stepCount)")
                Button {
                    Task {
                        HealthKitHelper().authorizeHealthKit()
                        HealthKitHelper().updateSteps()
                    }
                } label: {
                    Text("Set up")
                }
            }
    }
}

struct StepView_Previews: PreviewProvider {
    static var previews: some View {
        StepView()
    }
}
