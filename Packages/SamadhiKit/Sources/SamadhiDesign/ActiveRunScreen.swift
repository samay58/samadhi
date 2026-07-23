import SwiftUI

struct ActiveRunScreen: View {
    let state: RunViewState
    let send: @MainActor (RunAction) -> Void

    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ScrollView {
            VStack(spacing: Space.x4) {
                BrandMark(inverted: true)
                    .frame(width: 38, height: 28)
                    .padding(.top, Space.x6)

                Spacer(minLength: Space.x3)

                RhythmControl(
                    state: state,
                    mode: apertureMode,
                    size: apertureSize,
                    send: send
                )

                RunStatus(state: state)
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

                runDetails

                Spacer(minLength: Space.x6)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Space.x6)
        }
        .scrollIndicators(.hidden)
        .contentShape(Rectangle())
        // The full surface reveals low-attention controls; VoiceOver gets the same action without a tap target hunt.
        .onTapGesture(perform: showControls)
        .accessibilityAction(named: "Show controls", showControls)
        .accessibilityIdentifier("run-screen")
    }

    private var runDetails: some View {
        VStack(spacing: Space.x3) {
            TrackIdentity(track: state.track)

            Text(RunDurationText.formatted(state.trackElapsedSeconds))
                .font(.callout.monospacedDigit().weight(.semibold))
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                .foregroundStyle(SamadhiColor.ivory.opacity(0.82))
                .accessibilityLabel(
                    "Song position, \(RunDurationText.spoken(state.trackElapsedSeconds))"
                )

            if transportControlsVisible {
                TransportControls(state: state, send: send)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            finishControl
        }
        .padding(.horizontal, Space.x4)
        .padding(.vertical, Space.x4)
        .frame(maxWidth: 368)
        .background {
            Ellipse()
                .fill(SamadhiColor.ink.opacity(transportControlsVisible ? 0.56 : 0.42))
                .frame(width: 440, height: transportControlsVisible ? 300 : 190)
                .blur(radius: 54)
        }
    }

    @ViewBuilder
    private var finishControl: some View {
        if state.phase == .confirmingFinish {
            HoldToFinishControl(send: send, reduceMotionOverride: state.forceReduceMotion)
                .transition(.opacity)
        } else if transportControlsVisible {
            Button(action: beginFinish) {
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

    private var transportControlsVisible: Bool {
        state.controlsVisible || state.phase == .paused
    }

    private var apertureMode: ApertureMode {
        switch state.phase {
        case .preparing, .acquiring:
            .acquiring
        case .running:
            .locked
        case .paused:
            .paused
        case .confirmingFinish, .finishing:
            .interrupted
        default:
            .interrupted
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
        if dynamicTypeSize.isAccessibilitySize {
            return state.rhythmControl.isVisible ? 228 : 250
        }
        return state.rhythmControl.isVisible || state.controlsVisible ? 244 : 286
    }

    private func showControls() {
        guard state.phase == .running || state.phase == .acquiring else { return }
        guard !state.rhythmControl.isVisible else { return }
        send(.revealControls)
        if voiceOverEnabled { send(.controlsInteractionChanged(true)) }
    }

    private func beginFinish() {
        send(.finishTapped)
    }
}

private struct RunStatus: View {
    let state: RunViewState

    @ViewBuilder
    var body: some View {
        switch state.phase {
        case .preparing:
            statusText("Preparing your music")
        case .acquiring:
            statusText("Listening for your stride")
        case .running where state.showLockBrief:
            VStack(spacing: Space.x1) {
                Text("Tempo matched")
                    .font(.callout.weight(.semibold))
                HStack(alignment: .firstTextBaseline, spacing: Space.x2) {
                    Text("\(state.cadenceSPM ?? 168)")
                        .font(.title2.monospacedDigit().weight(.bold))
                    Text("steps per minute")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SamadhiColor.ivory.opacity(0.8))
                }
            }
            .accessibilityLabel("Tempo matched at \(state.cadenceSPM ?? 168) steps per minute")
            .accessibilityIdentifier("cadence-lock")
        case .paused:
            statusText("Paused", font: .headline)
        case .confirmingFinish:
            statusText("Keep holding to finish")
        case .finishing:
            statusText("Finishing")
        default:
            Color.clear.frame(height: 1)
        }
    }

    private func statusText(_ text: String, font: Font = .callout.weight(.semibold)) -> some View {
        Text(text)
            .font(font)
            .accessibilityIdentifier("run-status")
    }
}

private struct TrackIdentity: View {
    let track: TrackMetadata

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: Space.x1) {
            Text(track.title)
                .font(
                    .system(
                        size: dynamicTypeSize.isAccessibilitySize ? 24 : 29,
                        weight: .medium,
                        design: .serif
                    )
                )
                .tracking(-0.35)
                .lineLimit(3)
            Text(track.artist)
                .font(.body.weight(.medium))
                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                .foregroundStyle(SamadhiColor.ivory.opacity(0.82))
                .lineLimit(2)
        }
        .multilineTextAlignment(.center)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(track.title), by \(track.artist)")
        .accessibilityIdentifier("track-identity")
    }
}
