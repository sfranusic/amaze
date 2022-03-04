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
            .onAppear {
                Task {
                    do {
                        try await healthKitHelper.setUpAccessToStepData()
                    } catch {

                    }
                }
            }
            .alert(isPresented: $healthKitHelper.shouldAlert) {
                Alert(title: Text("Health Access Needed"),
                      message: Text("Access to Health data is necessary to show your step count."),
                      primaryButton: .default(Text("Settings"), action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }),
                      secondaryButton: .cancel(Text("Cancel")))
            }
    }
}

struct StepView_Previews: PreviewProvider {
    static var previews: some View {
        StepView()
    }
}
