import SamadhiDomain
import SwiftUI

public struct SamadhiScreen: View {
    let state: RunViewState
    let send: @MainActor (RunAction) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    public init(state: RunViewState, send: @escaping @MainActor (RunAction) -> Void) {
        self.state = state
        self.send = send
    }

    public var body: some View {
        ZStack {
            atmosphere
            content
        }
        .foregroundStyle(foregroundColor)
        .animation(effectiveReduceMotion ? nil : .smooth(duration: MotionToken.transition), value: state.phase)
        .animation(effectiveReduceMotion ? nil : .smooth(duration: MotionToken.control), value: state.controlsVisible)
    }

    @ViewBuilder
    private var content: some View {
        switch state.phase {
        case .ready:
            readyView
        case .permissionRecovery:
            permissionRecoveryView
        case let .routeRecovery(restored):
            routeRecoveryView(restored: restored)
        case let .summary(summary):
            summaryView(summary)
        case .preparing, .acquiring, .running, .paused, .confirmingFinish, .finishing:
            runView
        }
    }

    private var readyView: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: Space.x6) {
                    BrandMark()
                        .frame(width: 40, height: 30)
                        .padding(.top, Space.x8)

                    Spacer(minLength: Space.x8)

                    VStack(spacing: Space.x4) {
                        Text("Run with")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(SamadhiColor.ink.opacity(0.78))
                        Text(state.track.collection)
                            .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 42 : 52, weight: .medium, design: .serif))
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

                    Spacer(minLength: Space.x8)

                    Button { send(.start) } label: {
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

    private var runView: some View {
        ScrollView {
            VStack(spacing: Space.x4) {
                BrandMark(inverted: true)
                    .frame(width: 38, height: 28)
                    .padding(.top, Space.x6)

                Spacer(minLength: Space.x3)

                TempoAperture(
                    mode: apertureMode,
                    cadenceSPM: state.cadenceSPM,
                    progress: state.trackProgress,
                    reduceMotionOverride: state.forceReduceMotion,
                    increasedContrastOverride: state.forceIncreasedContrast
                )
                    .frame(width: apertureSize, height: apertureSize)
                    .accessibilityIdentifier(state.phase == .running ? "cadence-lock" : "tempo-aperture")

                statusView
                    .frame(minHeight: showsStatus ? 44 : 4)
                    .padding(.horizontal, showsStatus ? Space.x4 : 0)
                    .background {
                        if showsStatus {
                            Ellipse()
                                .fill(SamadhiColor.ink.opacity(0.38))
                                .frame(width: 210, height: 70)
                                .blur(radius: 24)
                        }
                    }
                    .transaction { transaction in
                        transaction.animation = nil
                    }

                VStack(spacing: Space.x3) {
                    trackIdentity

                    Text(formattedDuration(state.trackElapsedSeconds))
                        .font(.callout.monospacedDigit().weight(.semibold))
                        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                        .foregroundStyle(SamadhiColor.ivory.opacity(0.82))
                        .accessibilityLabel("Song position, \(spokenDuration(state.trackElapsedSeconds))")

                    if state.controlsVisible || state.phase == .paused {
                        transportControls
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    if state.phase == .confirmingFinish {
                        HoldToFinishControl(send: send, reduceMotionOverride: state.forceReduceMotion)
                            .transition(.opacity)
                    } else if state.controlsVisible || state.phase == .paused {
                        Button { send(.finishTapped) } label: {
                            Text("Finish")
                                .font(.body.weight(.semibold))
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                .frame(width: dynamicTypeSize.isAccessibilitySize ? 176 : 136, height: 48)
                        }
                            .buttonStyle(.glass)
                            .tint(SamadhiColor.ivory.opacity(0.2))
                            .accessibilityIdentifier("finish-run")
                            .accessibilityHint("Changes to a hold control so the run cannot end accidentally")
                    }
                }
                .padding(.horizontal, Space.x4)
                .padding(.vertical, Space.x4)
                .frame(maxWidth: 368)
                .background {
                    Ellipse()
                        .fill(SamadhiColor.ink.opacity(state.controlsVisible || state.phase == .paused ? 0.56 : 0.42))
                        .frame(width: 440, height: state.controlsVisible || state.phase == .paused ? 300 : 190)
                        .blur(radius: 54)
                }

                Spacer(minLength: Space.x6)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Space.x6)
        }
        .scrollIndicators(.hidden)
        .contentShape(Rectangle())
        .simultaneousGesture(TapGesture().onEnded {
            guard state.phase == .running || state.phase == .acquiring else { return }
            send(.revealControls)
            if voiceOverEnabled { send(.controlsFocusChanged(true)) }
        })
        .accessibilityAction(named: "Show controls") {
            send(.revealControls)
            if voiceOverEnabled { send(.controlsFocusChanged(true)) }
        }
        .accessibilityIdentifier("run-screen")
    }

    @ViewBuilder
    private var statusView: some View {
        switch state.phase {
        case .preparing:
            Text("Preparing your music")
                .font(.callout.weight(.semibold))
                .accessibilityIdentifier("run-status")
        case .acquiring:
            Text("Listening for your stride")
                .font(.callout.weight(.semibold))
                .accessibilityIdentifier("run-status")
        case .running where state.showLockBrief:
            HStack(alignment: .firstTextBaseline, spacing: Space.x2) {
                Text("\(state.cadenceSPM ?? 168)")
                    .font(.title2.monospacedDigit().weight(.bold))
                Text("steps per minute")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SamadhiColor.ivory.opacity(0.8))
            }
                .accessibilityLabel("In step at \(state.cadenceSPM ?? 168) steps per minute")
                .accessibilityIdentifier("cadence-lock")
        case .paused:
            Text("Paused")
                .font(.headline)
                .accessibilityIdentifier("run-status")
        case .confirmingFinish:
            Text("Keep holding to finish")
                .font(.callout)
                .accessibilityIdentifier("run-status")
        case .finishing:
            Text("Finishing")
                .accessibilityIdentifier("run-status")
        default:
            Color.clear.frame(height: 1)
        }
    }

    private var trackIdentity: some View {
        VStack(spacing: Space.x1) {
            Text(state.track.title)
                .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 24 : 29, weight: .medium, design: .serif))
                .tracking(-0.35)
                .lineLimit(3)
            Text(state.track.artist)
                .font(.body.weight(.medium))
                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                .foregroundStyle(SamadhiColor.ivory.opacity(0.82))
                .lineLimit(2)
        }
        .multilineTextAlignment(.center)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(state.track.title), by \(state.track.artist)")
        .accessibilityIdentifier("track-identity")
    }

    private var transportControls: some View {
        HStack(spacing: Space.x2) {
            transportButton("Previous", systemImage: "backward.end.fill", action: .previous, identifier: "previous-track")
            transportButton(
                state.phase == .paused ? "Resume" : "Pause",
                systemImage: state.phase == .paused ? "play.fill" : "pause.fill",
                action: state.phase == .paused ? .resume : .pause,
                identifier: state.phase == .paused ? "resume-run" : "pause-run"
            )
            transportButton("Skip", systemImage: "forward.end.fill", action: .skip, identifier: "skip-track")
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("transport-controls")
    }

    private func transportButton(_ title: String, systemImage: String, action: RunAction, identifier: String) -> some View {
        Button { send(action) } label: {
            if dynamicTypeSize.isAccessibilitySize {
                Image(systemName: systemImage)
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 58)
            } else {
                VStack(spacing: Space.x1) {
                    Image(systemName: systemImage)
                        .font(.body.weight(.semibold))
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, minHeight: 58)
            }
        }
        .buttonStyle(.glass)
        .tint(SamadhiColor.ivory.opacity(0.12))
        .accessibilityLabel(title)
        .accessibilityIdentifier(identifier)
    }

    private var permissionRecoveryView: some View {
        recoveryLayout(
            symbol: "figure.run",
            title: "Motion access is off",
            message: "Samadhi uses step rhythm to adapt the music. You can change access in Settings or continue at a fixed rhythm."
        ) {
            Button("Open Settings") { send(.openSettings) }
                .buttonStyle(.glassProminent)
                .tint(SamadhiColor.clay)
                .accessibilityIdentifier("open-settings")
            Button("Use fixed rhythm") { send(.useFixedRhythm) }
                .buttonStyle(.glass)
                .accessibilityIdentifier("use-fixed-rhythm")
        }
        .accessibilityIdentifier("permission-recovery")
    }

    private func routeRecoveryView(restored: Bool) -> some View {
        recoveryLayout(
            symbol: "airpodspro",
            title: "Headphones disconnected",
            message: restored ? "Your headphones are connected again. Resume when you’re ready." : "Music paused. Reconnect your headphones to continue safely."
        ) {
            if restored {
                Button("Resume") { send(.routeResume) }
                    .buttonStyle(.glassProminent)
                    .tint(SamadhiColor.clay)
                    .accessibilityIdentifier("route-resume")
            } else {
                Text("Waiting for headphones")
                    .font(.callout)
                    .foregroundStyle(SamadhiColor.ink.opacity(0.65))
            }
        }
        .accessibilityIdentifier("route-recovery")
    }

    private func recoveryLayout<Actions: View>(
        symbol: String,
        title: String,
        message: String,
        @ViewBuilder actions: () -> Actions
    ) -> some View {
        ScrollView {
            VStack(spacing: Space.x6) {
                Spacer(minLength: Space.x12)
                Image(systemName: symbol)
                    .font(.system(size: 52, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityHidden(true)
                Text(title)
                    .font(.system(size: 38, weight: .medium, design: .serif))
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                Text(message)
                    .font(.body.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(SamadhiColor.ink.opacity(0.82))
                    .frame(maxWidth: 330)
                actions()
                    .frame(minHeight: 52)
                Spacer(minLength: Space.x12)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Space.x6)
            .background {
                Ellipse()
                    .fill(SamadhiColor.parchment.opacity(0.76))
                    .frame(width: 450, height: 480)
                    .blur(radius: 58)
            }
            .padding(.horizontal, Space.x4)
        }
        .scrollIndicators(.hidden)
    }

    private func summaryView(_ summary: RunSummary) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                BrandMark()
                    .frame(width: 40, height: 30)
                    .padding(.top, Space.x8)

                Spacer(minLength: Space.x8)

                Text("Run complete")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(SamadhiColor.ink.opacity(0.72))
                Text(formattedDuration(summary.durationSeconds))
                    .font(.system(size: 68, weight: .medium, design: .serif).monospacedDigit())
                    .tracking(-2)
                    .accessibilityLabel(spokenDuration(summary.durationSeconds))
                    .accessibilityAddTraits(.isHeader)
                Text("total time")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(SamadhiColor.ink.opacity(0.62))

                SummaryRhythmGauge(progress: Double(summary.timeInStepPercent) / 100)
                    .frame(maxWidth: 330)
                    .padding(.top, Space.x8)

                summaryMetricRail(summary)
                    .frame(maxWidth: 330)
                    .padding(.top, Space.x6)

                Spacer(minLength: Space.x8)

                Button { send(.done) } label: {
                    Text("Done")
                        .font(.headline)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                        .frame(width: 164, height: 58)
                }
                    .buttonStyle(.glassProminent)
                    .tint(SamadhiColor.clay)
                    .accessibilityIdentifier("summary-done")

                Spacer(minLength: Space.x8)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Space.x8)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier("run-summary")
    }

    private func summaryMetricRail(_ summary: RunSummary) -> some View {
        let cadence = summary.averageCadence.map(String.init) ?? "Fixed"
        let cadenceLabel = summary.averageCadence == nil ? "rhythm" : "avg cadence"
        let cadenceSpoken = summary.averageCadence.map { "\($0) steps per minute" } ?? "Fixed rhythm"
        let songsLabel = summary.songCount == 1 ? "song" : "songs"

        return ViewThatFits(in: .horizontal) {
            HStack(spacing: 0) {
                summaryMetricColumn(value: cadence, label: cadenceLabel, spokenValue: cadenceSpoken)
                Rectangle()
                    .fill(SamadhiColor.ink.opacity(0.14))
                    .frame(width: 1, height: 46)
                summaryMetricColumn(value: "\(summary.songCount)", label: songsLabel, spokenValue: "\(summary.songCount) \(songsLabel)")
            }

            VStack(spacing: Space.x4) {
                summaryMetricRow(value: cadence, label: cadenceLabel, spokenValue: cadenceSpoken)
                summaryMetricRow(value: "\(summary.songCount)", label: songsLabel, spokenValue: "\(summary.songCount) \(songsLabel)")
            }
        }
    }

    private func summaryMetricColumn(value: String, label: String, spokenValue: String) -> some View {
        VStack(spacing: Space.x1) {
            Text(value)
                .font(.title2.monospacedDigit().weight(.bold))
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(SamadhiColor.ink.opacity(0.66))
        }
        .frame(maxWidth: .infinity)
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenValue)
    }

    private func summaryMetricRow(value: String, label: String, spokenValue: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Space.x2) {
            Text(value)
                .font(.title2.monospacedDigit().weight(.bold))
            Text(label)
                .font(.body.weight(.medium))
                .foregroundStyle(SamadhiColor.ink.opacity(0.72))
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenValue)
    }

    private var atmosphere: some View {
        Group {
            switch state.phase {
            case .ready:
                FluidMusicField(
                    mode: .ready,
                    usesCollectionPalette: state.hasArtwork,
                    reduceMotionOverride: state.forceReduceMotion,
                    animates: true
                )
            case .permissionRecovery, .routeRecovery, .summary:
                FluidMusicField(
                    mode: .ready,
                    usesCollectionPalette: false,
                    reduceMotionOverride: true,
                    animates: false
                )
            default:
                FluidMusicField(
                    mode: .running,
                    usesCollectionPalette: state.hasArtwork,
                    reduceMotionOverride: state.forceReduceMotion,
                    animates: state.phase == .preparing || state.phase == .acquiring
                )
            }
        }
        .ignoresSafeArea()
    }

    private var foregroundColor: Color {
        switch state.phase {
        case .ready, .permissionRecovery, .routeRecovery, .summary: SamadhiColor.ink
        default: SamadhiColor.ivory
        }
    }

    private var apertureMode: ApertureMode {
        switch state.phase {
        case .preparing, .acquiring: .acquiring
        case .running: .locked
        case .paused: .paused
        case .confirmingFinish, .finishing: .interrupted
        default: .interrupted
        }
    }

    private var showsStatus: Bool {
        switch state.phase {
        case .preparing, .acquiring, .paused, .confirmingFinish, .finishing:
            true
        case .running:
            state.showLockBrief
        default:
            false
        }
    }

    private var apertureSize: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 210 : (state.controlsVisible ? 244 : 286)
    }

    private func formattedDuration(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    private func spokenDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainder = seconds % 60
        return "\(minutes) minutes, \(remainder) seconds"
    }

    private var effectiveReduceMotion: Bool {
        reduceMotion || state.forceReduceMotion
    }
}

private struct SummaryRhythmGauge: View {
    let progress: Double

    var body: some View {
        VStack(spacing: Space.x2) {
            HStack(alignment: .firstTextBaseline) {
                Text("Rhythm held")
                    .font(.callout.weight(.semibold))
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.title3.monospacedDigit().weight(.bold))
            }

            Canvas { context, size in
                var path = Path()
                path.move(to: CGPoint(x: 3, y: size.height * 0.58))
                path.addCurve(
                    to: CGPoint(x: size.width - 3, y: size.height * 0.42),
                    control1: CGPoint(x: size.width * 0.3, y: -size.height * 0.08),
                    control2: CGPoint(x: size.width * 0.7, y: size.height * 1.08)
                )

                context.stroke(
                    path,
                    with: .color(SamadhiColor.ink.opacity(0.14)),
                    style: StrokeStyle(lineWidth: 7, lineCap: .round)
                )
                context.stroke(
                    path.trimmedPath(from: 0, to: min(max(progress, 0), 1)),
                    with: .linearGradient(
                        Gradient(colors: [SamadhiColor.clay, SamadhiColor.apricot, SamadhiColor.olive]),
                        startPoint: .zero,
                        endPoint: CGPoint(x: size.width, y: size.height)
                    ),
                    style: StrokeStyle(lineWidth: 7, lineCap: .round)
                )
            }
            .frame(height: 42)
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rhythm held for \(Int(progress * 100)) percent of the run")
    }
}

private struct HoldToFinishControl: View {
    let send: @MainActor (RunAction) -> Void
    let reduceMotionOverride: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var pressing = false

    var body: some View {
        Button {} label: {
            Text("Hold to finish")
                .font(.body.weight(.semibold))
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                .frame(width: dynamicTypeSize.isAccessibilitySize ? 220 : 190, height: 54)
        }
            .background(alignment: .leading) {
                Capsule()
                    .fill(SamadhiColor.clay.opacity(0.56))
                    .scaleEffect(x: pressing ? 1 : 0, y: 1, anchor: .leading)
                    .animation(reduceMotion || reduceMotionOverride ? nil : .linear(duration: 0.9), value: pressing)
            }
            .buttonStyle(.glassProminent)
            .tint(SamadhiColor.clay)
            .onLongPressGesture(
                minimumDuration: 0.9,
                maximumDistance: 24,
                perform: { send(.finishHoldCompleted) },
                onPressingChanged: { isPressing in
                    pressing = isPressing
                    send(isPressing ? .finishHoldBegan : .finishHoldCancelled)
                }
            )
            .accessibilityIdentifier("hold-to-finish")
            .accessibilityHint("Press and hold to end the run")
            .accessibilityAction(named: "Finish run") {
                send(.finishHoldBegan)
                send(.finishHoldCompleted)
            }
    }
}
