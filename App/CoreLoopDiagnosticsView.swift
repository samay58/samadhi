#if DEBUG
    import SamadhiDomain
    import SamadhiMotion
    import SwiftUI

    enum TempoDiagnosticStatus: String, CaseIterable, Sendable {
        case waiting
        case verified
        case limited
        case rejected

        var label: String {
            switch self {
            case .waiting: "Waiting for Apple Music"
            case .verified: "Verified by Apple Music"
            case .limited: "Limited by this song"
            case .rejected: "Rejected by Apple Music"
            }
        }
    }

    struct CoreLoopDiagnosticPresentation: Equatable, Sendable {
        let build: BuildIdentity
        let environment: DiagnosticEnvironment
        let measuredSongBPM: Double?
        let alternatePulseBPM: Double?
        let confidence: Double?
        let analyzedDurationSeconds: Double?
        let analyzerVersion: Int?
        let relationship: StepBeatRelationship?
        let originalStepRhythmSPM: Double?
        let rawStepSPM: Double?
        let smoothedStepSPM: Double?
        let sampleAgeSeconds: Double?
        let sampleDisposition: CadenceSampleDisposition?
        let settledAutoTargetSPM: Double?
        let autoTargetStatus: AutoTargetStatus
        let autoTargetText: String
        let controllingRhythmSPM: Double?
        let requiredRate: Double?
        let sentRate: Double?
        let reportedRate: Double?
        let reportTimeSeconds: Double?
        let resultingMusicalBPM: Double?
        let resultingStepRhythmSPM: Double?
        let remainingDifferenceSPM: Double?
        let autoCueText: String
        // What became of the last three cues the service handled, newest last.
        let cueDeliveryTexts: [String]
        let nextSongText: String
        let lastSongChangeText: String
        let status: TempoDiagnosticStatus

        init(
            state: RunState,
            collection: MusicCollection,
            cadenceSample: CadenceDiagnosticSample?,
            cueDeliveries: [AutoFeedbackDeliveryRecord] = [],
            build: BuildIdentity = .current,
            environment: DiagnosticEnvironment = .current
        ) {
            let session = state.session
            let track = session.flatMap { session in
                collection.tracks.indices.contains(session.trackIndex)
                    ? collection.tracks[session.trackIndex]
                    : nil
            }
            let tempo = track?.tempo
            let readback = session?.adaptationState.appliedRateReadback
            let stepRhythm = session?.adaptationState.baseTempoBPM ?? tempo?.stepPulseSPM
            let resultingStepRhythm = stepRhythm.flatMap { pulse in
                readback.map { pulse * $0 }
            }
            let controllingRhythm = session?.adaptationState.requestedBPM

            self.build = build
            self.environment = environment
            measuredSongBPM = session?.adaptationState.musicalTempoBPM ?? tempo?.baseBPM
            alternatePulseBPM = tempo?.alternatePulseBPM
            confidence = tempo?.confidence
            analyzedDurationSeconds = tempo?.analyzedDurationSeconds
            analyzerVersion = tempo?.version
            relationship =
                session?.adaptationState.stepBeatRelationship
                ?? tempo?.cadenceProjections.first?.relationship
            originalStepRhythmSPM = stepRhythm
            rawStepSPM = cadenceSample?.rawStepsPerMinute
            smoothedStepSPM =
                cadenceSample?.filteredStepsPerMinute
                ?? session?.adaptationState.lastReliableCadenceSPM
            sampleAgeSeconds = cadenceSample?.sampleAgeSeconds
            sampleDisposition = cadenceSample?.disposition
            let settledTarget = session?.autoTargetState.settledTargetSPM
            let targetStatus = session?.autoTargetState.status ?? .acquiring
            settledAutoTargetSPM = settledTarget
            autoTargetStatus = targetStatus
            if session?.rhythmControl.mode == .manual {
                autoTargetText =
                    settledTarget.map {
                        String(format: "Held at %.0f SPM while Manual controls this song.", $0)
                    } ?? "Manual controls this song while Auto waits for a settled target."
            } else {
                autoTargetText =
                    settledTarget.map {
                        String(format: "%.0f SPM, %@", $0, Self.autoStatusLabel(targetStatus))
                    } ?? Self.autoStatusLabel(targetStatus)
            }
            controllingRhythmSPM = controllingRhythm
            requiredRate = session?.adaptationState.derivedTargetRate
            sentRate = session?.adaptationState.commandedRate
            reportedRate = readback
            reportTimeSeconds = session?.adaptationState.commandLatencySeconds
            resultingMusicalBPM = tempo.flatMap { tempo in
                readback.map { tempo.baseBPM * $0 }
            }
            resultingStepRhythmSPM = resultingStepRhythm
            remainingDifferenceSPM = controllingRhythm.flatMap { target in
                resultingStepRhythm.map { $0 - target }
            }
            autoCueText = Self.autoCueLabel(session?.autoFeedback.transaction)
            cueDeliveryTexts = cueDeliveries.map(Self.deliveryLabel)
            nextSongText = Self.nextSongLabel(session, collection: collection)
            lastSongChangeText = Self.songChangeLabel(session?.lastTrackChangeReason)
            status = Self.status(for: session)
        }

        private static func status(for session: RunSession?) -> TempoDiagnosticStatus {
            guard let session else { return .waiting }
            if session.pendingRateRequestID != nil || session.adaptationState.commandStatus == .applying {
                return .waiting
            }
            if session.adaptationState.commandStatus == .rejected { return .rejected }
            if session.adaptationState.isAtLimit
                || session.adaptationState.commandStatus == .unreachable
            {
                return .limited
            }
            return session.adaptationState.commandStatus == .applied ? .verified : .waiting
        }

        static func fixture(_ status: TempoDiagnosticStatus) -> CoreLoopDiagnosticPresentation {
            let build = BuildIdentity.current
            let environment = DiagnosticEnvironment.current
            let reportedRate: Double? = status == .waiting ? nil : (status == .rejected ? 1 : 1.04)
            let resultingRunning = reportedRate.map { 168 * $0 }
            return CoreLoopDiagnosticPresentation(
                build: build,
                environment: environment,
                measuredSongBPM: 84,
                alternatePulseBPM: 168,
                confidence: 0.94,
                analyzedDurationSeconds: 30,
                analyzerVersion: 4,
                relationship: .twoStepsPerBeat,
                originalStepRhythmSPM: 168,
                rawStepSPM: 176,
                smoothedStepSPM: 175,
                sampleAgeSeconds: 2.57,
                sampleDisposition: .acceptedDelayed,
                settledAutoTargetSPM: 175,
                autoTargetStatus: .settled,
                autoTargetText: "175 SPM, settled",
                controllingRhythmSPM: 175,
                requiredRate: 1.0417,
                sentRate: 1.042,
                reportedRate: reportedRate,
                reportTimeSeconds: reportedRate == nil ? nil : 0.08,
                resultingMusicalBPM: reportedRate.map { 84 * $0 },
                resultingStepRhythmSPM: resultingRunning,
                remainingDifferenceSPM: resultingRunning.map { $0 - 175 },
                autoCueText: "Cue 1, faster, medium, began",
                cueDeliveryTexts: [
                    "Cue 1 began: played through the engine (pulse, Core Haptics audio)",
                    "Cue 1 arrived: played through the engine (pulse, Core Haptics audio)",
                ],
                nextSongText: "Queued song fits",
                lastSongChangeText: "Natural end of the song",
                status: status
            )
        }

        private init(
            build: BuildIdentity,
            environment: DiagnosticEnvironment,
            measuredSongBPM: Double?,
            alternatePulseBPM: Double?,
            confidence: Double?,
            analyzedDurationSeconds: Double?,
            analyzerVersion: Int?,
            relationship: StepBeatRelationship?,
            originalStepRhythmSPM: Double?,
            rawStepSPM: Double?,
            smoothedStepSPM: Double?,
            sampleAgeSeconds: Double?,
            sampleDisposition: CadenceSampleDisposition?,
            settledAutoTargetSPM: Double?,
            autoTargetStatus: AutoTargetStatus,
            autoTargetText: String,
            controllingRhythmSPM: Double?,
            requiredRate: Double?,
            sentRate: Double?,
            reportedRate: Double?,
            reportTimeSeconds: Double?,
            resultingMusicalBPM: Double?,
            resultingStepRhythmSPM: Double?,
            remainingDifferenceSPM: Double?,
            autoCueText: String,
            cueDeliveryTexts: [String],
            nextSongText: String,
            lastSongChangeText: String,
            status: TempoDiagnosticStatus
        ) {
            self.build = build
            self.environment = environment
            self.measuredSongBPM = measuredSongBPM
            self.alternatePulseBPM = alternatePulseBPM
            self.confidence = confidence
            self.analyzedDurationSeconds = analyzedDurationSeconds
            self.analyzerVersion = analyzerVersion
            self.relationship = relationship
            self.originalStepRhythmSPM = originalStepRhythmSPM
            self.rawStepSPM = rawStepSPM
            self.smoothedStepSPM = smoothedStepSPM
            self.sampleAgeSeconds = sampleAgeSeconds
            self.sampleDisposition = sampleDisposition
            self.settledAutoTargetSPM = settledAutoTargetSPM
            self.autoTargetStatus = autoTargetStatus
            self.autoTargetText = autoTargetText
            self.controllingRhythmSPM = controllingRhythmSPM
            self.requiredRate = requiredRate
            self.sentRate = sentRate
            self.reportedRate = reportedRate
            self.reportTimeSeconds = reportTimeSeconds
            self.resultingMusicalBPM = resultingMusicalBPM
            self.resultingStepRhythmSPM = resultingStepRhythmSPM
            self.remainingDifferenceSPM = remainingDifferenceSPM
            self.autoCueText = autoCueText
            self.cueDeliveryTexts = cueDeliveryTexts
            self.nextSongText = nextSongText
            self.lastSongChangeText = lastSongChangeText
            self.status = status
        }

        private static func deliveryLabel(_ record: AutoFeedbackDeliveryRecord) -> String {
            let outcome: String
            switch record.outcome {
            case .playedThroughEngine: outcome = "played through the engine"
            case .playedLocalSoundOnly: outcome = "local sound only, no haptic"
            case .engineUnavailable: outcome = "engine unavailable"
            case .patternMissing: outcome = "pattern missing"
            case .cancelledBeforePlay: outcome = "cancelled before it played"
            }
            let path: String
            switch record.soundPath {
            case .coreHaptics: path = "Core Haptics audio"
            case .avAudioPlayer: path = "local audio player"
            }
            var text =
                "Cue \(record.transactionID) \(record.moment.rawValue): \(outcome) "
                + "(\(record.family.rawValue), \(path))"
            if let detail = record.detail, !detail.isEmpty {
                text += ", \(detail)"
            }
            return text
        }

        private static func nextSongLabel(_ session: RunSession?, collection: MusicCollection) -> String {
            guard let session else { return "No run" }
            let planned = (session.preparedNextTrackID ?? session.pendingNextTrackID).flatMap { id in
                collection.tracks.first { $0.id == id }?.title
            }
            switch session.nextSongOutlook {
            case .notYetKnown:
                return planned.map { "Prepared \($0) for this song's limit" } ?? "Not judged yet"
            case .queuedSongFits:
                return "Queued song fits"
            case .betterFitPrepared:
                return planned.map { "Prepared \($0) for the boundary" } ?? "Preparing a better fit"
            case .nothingFits:
                return "Nothing in the collection fits; queue proceeds"
            }
        }

        private static func autoCueLabel(_ transaction: AutoFeedbackTransaction?) -> String {
            guard let transaction else { return "No Auto cue in flight" }
            let phase: String
            switch transaction.phase {
            case .committed: phase = "committed, waiting for Apple Music"
            case .began: phase = "began"
            case .arrived: phase = transaction.isLimited ? "arrived at this song's limit" : "arrived"
            }
            return String(
                format: "Cue %d, %@, %@, %@ (%+.0f SPM)",
                transaction.id,
                transaction.direction.rawValue,
                transaction.size.rawValue,
                phase,
                transaction.changeSPM
            )
        }

        private static func songChangeLabel(_ reason: TrackChangeReason?) -> String {
            switch reason {
            case .explicitPrevious: "Previous requested here"
            case .explicitSkip: "Next requested here"
            case .naturalBoundary: "Natural end of the song"
            case .externalUnknown: "Changed outside Samadhi"
            case .recovery: "Recovery"
            case nil: "No confirmed song change yet"
            }
        }

        private static func autoStatusLabel(_ status: AutoTargetStatus) -> String {
            switch status {
            case .acquiring: "finding a steady rhythm"
            case .settled: "settled"
            case .considering: "checking a sustained change"
            case .holding: "holding during missing readings"
            }
        }
    }

    struct CoreLoopDiagnosticsView: View {
        let presentation: CoreLoopDiagnosticPresentation

        var body: some View {
            NavigationStack {
                List {
                    Section("Exact app build") {
                        row("Code version", presentation.build.gitCommit)
                            .accessibilityIdentifier("build-identity-value")
                        row(
                            "Branch",
                            presentation.build.gitBranch
                                + (presentation.build.trackedFilesDirty ? ", tracked files changed" : ", clean")
                        )
                        row("Built", presentation.build.buildDate)
                        row("Source fingerprint", presentation.build.sourceFingerprint)
                            .accessibilityIdentifier("source-fingerprint-value")
                        row(
                            "App",
                            "\(presentation.build.appVersion) (\(presentation.build.buildNumber))"
                        )
                        row("Tempo analyzer", "version \(presentation.build.tempoAnalyzerVersion)")
                        row("Diagnostic file", "version \(presentation.build.diagnosticFileVersion)")
                    }

                    Section("Test environment") {
                        row("Device", presentation.environment.deviceModel)
                        row("System", presentation.environment.operatingSystem)
                        row("Music", presentation.environment.musicService)
                        row("Motion", presentation.environment.motionService)
                        row(
                            "Launch options",
                            presentation.environment.launchArguments.isEmpty
                                ? "none"
                                : presentation.environment.launchArguments.joined(separator: " ")
                        )
                    }

                    Section("What the song contains") {
                        row("Measured song speed", bpm(presentation.measuredSongBPM))
                            .accessibilityIdentifier("measured-song-speed")
                        row("Alternate supported pulse", bpm(presentation.alternatePulseBPM))
                        row("Analysis confidence", percent(presentation.confidence))
                        row("Audio analyzed", seconds(presentation.analyzedDurationSeconds))
                        row("Analyzer used", integer(presentation.analyzerVersion))
                        row("Step relationship", relationship(presentation.relationship))
                            .accessibilityIdentifier("step-relationship")
                        row("Original step rhythm", spm(presentation.originalStepRhythmSPM))
                            .accessibilityIdentifier("original-step-rhythm")
                    }

                    Section("What the phone sensed") {
                        row("Raw step reading", spm(presentation.rawStepSPM))
                        row("Smoothed step reading", spm(presentation.smoothedStepSPM))
                        row("Sensor sample age", seconds(presentation.sampleAgeSeconds))
                        row("Sensor sample", disposition(presentation.sampleDisposition))
                            .accessibilityIdentifier("sensor-sample-status")
                        LabeledContent("Auto target") {
                            Text(presentation.autoTargetText)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(.secondary)
                                .accessibilityIdentifier("settled-auto-target")
                        }
                    }

                    Section("What changed in Apple Music") {
                        row("Rhythm controlling the song", spm(presentation.controllingRhythmSPM))
                        row("Playback speed required", rate(presentation.requiredRate))
                        row("Playback speed sent", rate(presentation.sentRate))
                        row("Apple Music reported", rate(presentation.reportedRate))
                            .accessibilityIdentifier("apple-music-reported-rate")
                        row("Apple Music report time", seconds(presentation.reportTimeSeconds))
                        row("Resulting musical speed", bpm(presentation.resultingMusicalBPM))
                            .accessibilityIdentifier("resulting-musical-speed")
                        row("Resulting step rhythm", spm(presentation.resultingStepRhythmSPM))
                            .accessibilityIdentifier("resulting-step-rhythm")
                        row("Difference from target", signedSPM(presentation.remainingDifferenceSPM))
                        row("Auto cue", presentation.autoCueText)
                            .accessibilityIdentifier("auto-cue")
                        row("Next song", presentation.nextSongText)
                            .accessibilityIdentifier("next-song-outlook")
                        row("Last song change", presentation.lastSongChangeText)
                            .accessibilityIdentifier("last-song-change")
                        Text(presentation.status.label)
                            .font(.headline)
                            .foregroundStyle(statusColor)
                            .accessibilityIdentifier("tempo-command-status")
                    }

                    Section("What became of the cues") {
                        if presentation.cueDeliveryTexts.isEmpty {
                            Text("No cue has been handled yet")
                                .foregroundStyle(.secondary)
                                .accessibilityIdentifier("cue-delivery-empty")
                        } else {
                            ForEach(Array(presentation.cueDeliveryTexts.enumerated()), id: \.offset) { index, text in
                                Text(text)
                                    .foregroundStyle(.secondary)
                                    .accessibilityIdentifier("cue-delivery-\(index)")
                            }
                        }
                    }

                    Section("Speed comparison") {
                        Text(
                            "The Debug MusicKit gate keeps the normal-speed and changed-speed listening controls. This screen reports the exact rate Apple Music returned."
                        )
                        .foregroundStyle(.secondary)
                    }
                }
                .navigationTitle("What Samadhi saw")
                .navigationBarTitleDisplayMode(.inline)
            }
            .accessibilityIdentifier("core-loop-diagnostics")
        }

        private var statusColor: Color {
            switch presentation.status {
            case .waiting: .orange
            case .verified: .green
            case .limited: .blue
            case .rejected: .red
            }
        }

        private func row(_ title: String, _ value: String) -> some View {
            LabeledContent(title, value: value)
        }

        private func bpm(_ value: Double?) -> String {
            value.map { String(format: "%.1f BPM", $0) } ?? "Not available"
        }

        private func spm(_ value: Double?) -> String {
            value.map { String(format: "%.1f SPM", $0) } ?? "Not available"
        }

        private func signedSPM(_ value: Double?) -> String {
            value.map { String(format: "%+.1f SPM", $0) } ?? "Not available"
        }

        private func rate(_ value: Double?) -> String {
            value.map { String(format: "%.3f×", $0) } ?? "Not available"
        }

        private func percent(_ value: Double?) -> String {
            value.map { String(format: "%.0f%%", $0 * 100) } ?? "Not available"
        }

        private func seconds(_ value: Double?) -> String {
            value.map { String(format: "%.2f seconds", $0) } ?? "Not available"
        }

        private func integer(_ value: Int?) -> String {
            value.map(String.init) ?? "Not available"
        }

        private func relationship(_ value: StepBeatRelationship?) -> String {
            switch value {
            case .oneStepPerBeat: "One step per beat"
            case .twoStepsPerBeat: "Two steps per beat"
            case nil: "Not available"
            }
        }

        private func disposition(_ value: CadenceSampleDisposition?) -> String {
            switch value {
            case .acceptedFresh: "Accepted, fresh"
            case .acceptedDelayed: "Accepted, delayed but new"
            case .missingValue: "No cadence in this sample"
            case .outsideSupportedRange: "Outside the supported step range"
            case .staleSample: "Rejected as stale"
            case .repeatedTimestamp: "Rejected as repeated"
            case .backwardTimestamp: "Rejected as backward"
            case .outOfOrderCallback: "Rejected as out of order"
            case .unexplainedGap: "Rejected after an unexplained gap"
            case nil: "Not available"
            }
        }
    }
#endif
