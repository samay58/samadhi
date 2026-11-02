import Foundation

// Which song plays next, and when the reducer may prepare it. Transport still commits it only on
// Skip or a player-confirmed natural boundary.
extension RunReducer {
    // The player slots a prepared song in during the last eight seconds of the current one, so the
    // reducer must have chosen it before then. Progress arrives about once a second.
    static let boundaryLookAheadSeconds = 45.0

    // Two ways a next song gets prepared. While the current song is pinned at its limit, the best
    // fit for the request replaces it after five seconds of evidence. Otherwise, inside the
    // look-ahead window, the queued song is judged against the settled Auto target and replaced
    // only when it cannot reach that target and something in the collection can.
    func planTrackTransition(
        session: RunSession,
        deltaSeconds: Double,
        selectionID: Int,
        prepareImmediately: Bool = false
    ) -> (session: RunSession, effects: [RunEffect]) {
        var next = session
        if session.adaptationState.isAtLimit,
            let requestedBPM = session.adaptationState.requestedBPM,
            let match = TrackMatchPlanner().select(
                requestedBPM: requestedBPM,
                from: tracks,
                currentTrackID: session.currentTrackID
            ),
            match.trackID != session.currentTrackID
        {
            next.incompatibleTrackSeconds =
                prepareImmediately
                ? 5
                : next.incompatibleTrackSeconds + max(deltaSeconds, 0)
            guard next.incompatibleTrackSeconds >= 5 else { return (next, []) }
            return prepare(match.trackID, in: next, selectionID: selectionID)
        }

        next.incompatibleTrackSeconds = 0
        let outlook = boundaryOutlook(for: session)
        next.nextSongOutlook = outlook.outlook
        if let trackID = outlook.prepareTrackID {
            return prepare(trackID, in: next, selectionID: selectionID)
        }

        let shouldClearPlan =
            next.pendingTrackSelectionID != nil
            || next.preparedNextTrackID != nil
        next.pendingTrackSelectionID = nil
        next.pendingNextTrackID = nil
        next.preparedNextTrackID = nil
        return (
            next,
            shouldClearPlan
                ? [
                    .clearPreparedNextTrack(
                        sessionID: session.id,
                        operationID: session.playbackOperationID,
                        selectionID: selectionID
                    )
                ]
                : []
        )
    }

    private func prepare(
        _ trackID: MusicTrackID,
        in session: RunSession,
        selectionID: Int
    ) -> (session: RunSession, effects: [RunEffect]) {
        var next = session
        guard next.pendingNextTrackID != trackID,
            next.preparedNextTrackID != trackID
        else { return (next, []) }
        next.pendingTrackSelectionID = selectionID
        next.pendingNextTrackID = trackID
        next.preparedNextTrackID = nil
        return (
            next,
            [
                .prepareNextTrack(
                    sessionID: session.id,
                    operationID: session.playbackOperationID,
                    selectionID: selectionID,
                    trackID: trackID
                )
            ]
        )
    }

    // One choice, kept once made: a plan that still fits the target is not traded for a marginally
    // better one, because hunting between songs near a boundary is worse than either song.
    private func boundaryOutlook(
        for session: RunSession
    ) -> (outlook: NextSongOutlook, prepareTrackID: MusicTrackID?) {
        guard session.mode == .adaptive,
            !tracks.isEmpty,
            let duration = session.trackDurationSeconds,
            duration > 0,
            Double(duration - session.trackElapsedSeconds) <= Self.boundaryLookAheadSeconds,
            let target = session.autoTargetState.settledTargetSPM
        else { return (.notYetKnown, nil) }

        let planner = TrackMatchPlanner()
        if let planned = session.preparedNextTrackID ?? session.pendingNextTrackID,
            let track = tracks.first(where: { $0.id == planned }),
            planner.fit(of: track, requestedBPM: target) != nil
        {
            return (.betterFitPrepared, planned)
        }

        let queued = tracks[(session.queueAnchorIndex + 1) % tracks.count]
        if queued.id != session.currentTrackID, planner.fit(of: queued, requestedBPM: target) != nil {
            return (.queuedSongFits, nil)
        }
        let candidates = tracks.filter { $0.id != session.currentTrackID && $0.id != queued.id }
        guard let match = planner.select(requestedBPM: target, from: candidates) else {
            return (.nothingFits, nil)
        }
        return (.betterFitPrepared, match.trackID)
    }
}
