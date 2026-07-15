import SamadhiDesign
import SwiftUI

struct RootView: View {
    // RootView owns the app's one presentation model. Screens receive rendered state and send intent back.
    @State private var model = RunPresentationModel()

    var body: some View {
        SamadhiScreen(state: model.viewState) { action in
            model.send(action)
        }
    }
}
