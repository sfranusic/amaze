//  Created by Sam Franusic on 3/22/22.

import SwiftUI

struct StepListView: View {

    @StateObject var healthKitHelper = HealthKitController()
    var body: some View {
        List(healthKitHelper.stepDataList, id: \.id) { step in
            StepListRow(data: step)
        }
        .onAppear {
            Task {
                do {
                    try await healthKitHelper.setUpAccessToStepData()
                } catch {

                }
            }
        }
    }

}

struct StepListView_Previews: PreviewProvider {
    static var previews: some View {
        StepListView()
    }
}
