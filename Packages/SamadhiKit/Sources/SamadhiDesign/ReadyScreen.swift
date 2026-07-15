import SwiftUI

struct ReadyScreen: View {
    let state: RunViewState
    let send: @MainActor (RunAction) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: Space.x6) {
                    BrandMark()
                        .frame(width: 40, height: 30)
                        .padding(.top, Space.x8)

                    Spacer(minLength: Space.x8)

                    collectionIdentity

                    Spacer(minLength: Space.x8)

                    Button(action: start) {
                        Text("Start")
                            .font(.title3.weight(.bold))
                            .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                            .frame(width: 184, height: 64)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(SamadhiColor.clay)
                    .shadow(color: SamadhiColor.clay.opacity(0.3), radius: 20, y: 10)
                    .accessibilityIdentifier("start-run")
                    .accessibilityHint("Starts the music and listens for your stride")

                    Text("Start moving. The music will find your stride.")
                        .font(.callout.weight(.medium))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(SamadhiColor.ink.opacity(0.82))
                        .padding(.horizontal, Space.x8)

                    Label("Demo collection", systemImage: "music.note")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(SamadhiColor.ink.opacity(0.76))
                        .padding(.bottom, Space.x6)
                }
                .frame(maxWidth: .infinity, minHeight: geometry.size.height)
                .padding(.horizontal, Space.x6)
            }
            .scrollIndicators(.hidden)
        }
        .accessibilityIdentifier("ready-screen")
    }

    private var collectionIdentity: some View {
        VStack(spacing: Space.x4) {
            Text("Run with")
                .font(.callout.weight(.semibold))
                .foregroundStyle(SamadhiColor.ink.opacity(0.78))
            Text(state.track.collection)
                .font(
                    .system(
                        size: dynamicTypeSize.isAccessibilitySize ? 42 : 52,
                        weight: .medium,
                        design: .serif
                    )
                )
                .tracking(-1.2)
                .lineSpacing(-4)
                .multilineTextAlignment(.center)
                .foregroundStyle(SamadhiColor.ink)
                .shadow(color: SamadhiColor.ivory.opacity(0.78), radius: 16)
                .accessibilityAddTraits(.isHeader)
            Text("A rhythm-ready demo collection")
                .font(.body.weight(.medium))
                .foregroundStyle(SamadhiColor.ink.opacity(0.8))
        }
        .padding(.horizontal, Space.x6)
        .padding(.vertical, Space.x8)
        .frame(maxWidth: 360)
        .background {
            Ellipse()
                .fill(SamadhiColor.parchment.opacity(0.78))
                .frame(width: 430, height: 250)
                .blur(radius: 46)
        }
    }

    private func start() {
        send(.start)
    }
}
