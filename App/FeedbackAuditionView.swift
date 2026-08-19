#if DEBUG
    import SamadhiDomain
    import SwiftUI
    import UIKit

    // Hidden Debug surface for comparing the prototype cue families by hand. It never decides when a
    // real Auto cue is valid; it only asks the shell service to play one.
    struct FeedbackAuditionView: View {
        private static let directions: [AutoFeedbackDirection] = [.faster, .slower]
        private static let sizes: [AutoFeedbackSize] = [.small, .medium, .large]
        private static let trialCount = 10

        @State private var service = AutoFeedbackService()
        @State private var family: AutoFeedbackFamily = .pulse
        @State private var direction: AutoFeedbackDirection = .faster
        @State private var size: AutoFeedbackSize = .medium
        @State private var soundPath: AutoFeedbackSoundPath = .coreHaptics
        @State private var hapticsEnabled = true
        @State private var soundEnabled = true
        @State private var nextTransactionID = 1
        @State private var seedText = "20260818"
        @State private var trial = BlindedTrial()

        var body: some View {
            NavigationStack {
                List {
                    Section("Family") {
                        Picker("Family", selection: $family) {
                            ForEach(AutoFeedbackFamily.allCases, id: \.self) { candidate in
                                Text(candidate.displayName).tag(candidate)
                            }
                        }
                        .pickerStyle(.segmented)
                        .accessibilityIdentifier("audition-family")
                    }

                    Section("Cue") {
                        Picker("Direction", selection: $direction) {
                            ForEach(Self.directions, id: \.self) { candidate in
                                Text(candidate.rawValue.capitalized).tag(candidate)
                            }
                        }
                        .pickerStyle(.segmented)
                        .accessibilityIdentifier("audition-direction")

                        Picker("Size", selection: $size) {
                            ForEach(Self.sizes, id: \.self) { candidate in
                                Text(candidate.rawValue.capitalized).tag(candidate)
                            }
                        }
                        .pickerStyle(.segmented)
                        .accessibilityIdentifier("audition-size")
                    }

                    Section("Output") {
                        Picker("Sound path", selection: $soundPath) {
                            ForEach(AutoFeedbackSoundPath.allCases, id: \.self) { candidate in
                                Text(candidate.displayName).tag(candidate)
                            }
                        }
                        .accessibilityIdentifier("audition-sound-path")

                        Toggle("Haptics", isOn: $hapticsEnabled)
                            .accessibilityIdentifier("audition-haptics")
                        Toggle("Sound", isOn: $soundEnabled)
                            .accessibilityIdentifier("audition-sound")
                    }

                    Section("Play") {
                        Button("Play start") { playStart(direction) }
                            .accessibilityIdentifier("audition-play-start")
                        Button("Play arrival") { playArrival(direction) }
                            .accessibilityIdentifier("audition-play-arrival")
                        Button("Play both") { playBoth(direction) }
                            .accessibilityIdentifier("audition-play-both")
                    }

                    Section("Blinded trial") {
                        LabeledContent("Seed") {
                            TextField("Seed", text: $seedText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .accessibilityIdentifier("audition-seed")
                        }
                        blindedTrialContent
                    }

                    Section("Truth boundary") {
                        Text(
                            "These patterns and sounds are offline prototypes. Simulator can show that a cue "
                                + "was requested. Only the phone can judge how it feels or sounds over music."
                        )
                        .foregroundStyle(.secondary)
                    }
                }
                .navigationTitle("Feedback audition")
                .navigationBarTitleDisplayMode(.inline)
            }
            .accessibilityIdentifier("feedback-audition")
        }

        @ViewBuilder
        private var blindedTrialContent: some View {
            if trial.sequence.isEmpty {
                Button("Start \(Self.trialCount) trials") { startTrials() }
                    .accessibilityIdentifier("audition-start-trials")
            } else if trial.index < trial.sequence.count {
                LabeledContent("Trial", value: "\(trial.index + 1) of \(trial.sequence.count)")
                Button("Play cue") { playBoth(trial.sequence[trial.index]) }
                    .accessibilityIdentifier("audition-trial-play")
                Button("Faster") { answer(.faster) }
                    .accessibilityIdentifier("audition-answer-faster")
                Button("Slower") { answer(.slower) }
                    .accessibilityIdentifier("audition-answer-slower")
                Button("Stop trials", role: .destructive) { trial = BlindedTrial() }
            } else {
                LabeledContent("Score", value: "\(trial.correct) of \(trial.sequence.count)")
                    .accessibilityIdentifier("audition-score")
                Text(summaryLine)
                    .font(.system(.footnote, design: .monospaced))
                    .textSelection(.enabled)
                    .accessibilityIdentifier("audition-summary")
                Button("Copy summary") { UIPasteboard.general.string = summaryLine }
                Button("New trials") { startTrials() }
            }
        }

        private var summaryLine: String {
            "Auto feedback blinded trial: family \(family.rawValue), sound \(soundPath.rawValue), "
                + "size \(size.rawValue), haptics \(hapticsEnabled), sound on \(soundEnabled), "
                + "seed \(seedText), score \(trial.correct) of \(trial.sequence.count)"
        }

        private func applySettings() {
            service.family = family
            service.soundPath = soundPath
            service.hapticsEnabled = hapticsEnabled
            service.soundEnabled = soundEnabled
        }

        private func claimTransactionID() -> Int {
            let identifier = nextTransactionID
            nextTransactionID += 1
            return identifier
        }

        private func cue(
            _ moment: AutoFeedbackMoment,
            _ cueDirection: AutoFeedbackDirection,
            transactionID: Int
        ) -> AutoFeedbackCue {
            AutoFeedbackCue(
                transactionID: transactionID,
                moment: moment,
                direction: cueDirection,
                size: size,
                isLimited: false
            )
        }

        private func playStart(_ cueDirection: AutoFeedbackDirection) {
            applySettings()
            service.play(cue(.began, cueDirection, transactionID: claimTransactionID()))
        }

        private func playArrival(_ cueDirection: AutoFeedbackDirection) {
            applySettings()
            service.play(cue(.arrived, cueDirection, transactionID: claimTransactionID()))
        }

        private func playBoth(_ cueDirection: AutoFeedbackDirection) {
            applySettings()
            let identifier = claimTransactionID()
            service.play(cue(.began, cueDirection, transactionID: identifier))
            service.play(cue(.arrived, cueDirection, transactionID: identifier))
        }

        private func startTrials() {
            var generator = SeededGenerator(seed: UInt64(seedText) ?? 0)
            trial = BlindedTrial(
                sequence: (0..<Self.trialCount).map { _ in
                    Bool.random(using: &generator) ? AutoFeedbackDirection.faster : .slower
                }
            )
        }

        private func answer(_ answered: AutoFeedbackDirection) {
            guard trial.index < trial.sequence.count else { return }
            if answered == trial.sequence[trial.index] { trial.correct += 1 }
            trial.index += 1
        }
    }

    private struct BlindedTrial {
        var sequence: [AutoFeedbackDirection] = []
        var index = 0
        var correct = 0
    }

    // SplitMix64 so a written-down seed reproduces the same blinded order on another day.
    private struct SeededGenerator: RandomNumberGenerator {
        private var state: UInt64

        init(seed: UInt64) {
            state = seed
        }

        mutating func next() -> UInt64 {
            state &+= 0x9E37_79B9_7F4A_7C15
            var mixed = state
            mixed = (mixed ^ (mixed >> 30)) &* 0xBF58_476D_1CE4_E5B9
            mixed = (mixed ^ (mixed >> 27)) &* 0x94D0_49BB_1331_11EB
            return mixed ^ (mixed >> 31)
        }
    }

    #Preview {
        FeedbackAuditionView()
    }
#endif
