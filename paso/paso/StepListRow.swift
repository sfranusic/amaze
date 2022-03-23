//  Created by Sam Franusic on 3/21/22.

import SwiftUI

struct StepRowData: Hashable {
    var id: Int
    var steps: Int
    var timeStamp: String

    init(steps: Int) {
        self.steps = steps
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        timeStamp = formatter.string(from: .now)
        formatter.dateStyle = .none
        id = Int((timeStamp.compactMap { $0.isNumber ? String($0) : nil}).joined()) ?? 0
    }
}

struct StepListRow: View {
    var data: StepRowData

    var body: some View {
        HStack {
            Text(data.timeStamp)
                .foregroundColor(.blue)
            Text("\(data.steps)")
                .foregroundColor(.blue)
            Spacer()
        }
    }
}

struct StepListRow_Previews: PreviewProvider {
    static var previews: some View {
        StepListRow(data: StepRowData(steps: 0))
    }
}
