import SwiftUI

public struct MilestoneZeroView: View {
    public init() {}

    public var body: some View {
        ZStack {
            Color(red: 0.09, green: 0.08, blue: 0.07)
                .ignoresSafeArea()

            Text("In Step")
                .font(.title)
                .foregroundStyle(Color(red: 0.95, green: 0.92, blue: 0.85))
        }
    }
}

#Preview("Milestone 0 shell") {
    MilestoneZeroView()
}

