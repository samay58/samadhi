import SamadhiDesign
import SwiftUI

struct RootView: View {
    @State private var model = RunPresentationModel()

    var body: some View {
        SamadhiScreen(state: model.viewState) { action in
            model.send(action)
        }
    }
}

