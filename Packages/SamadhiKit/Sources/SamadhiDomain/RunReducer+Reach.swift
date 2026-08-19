// Whether the collection can follow the body at all. When most ready songs cannot reach the
// settled Auto target inside the rate window, the runner deserves one plain sentence, not a rate
// pinned at its limit second after second with no word about why. The reducer owns the rule; the
// shell only shows the line it is handed.
extension RunReducer {
    // Fewer than this share of ready songs reachable counts as out of reach.
    static let reachableShareFloor = 0.25
    // The condition must hold this long before it is said, so a passing cadence dip says nothing.
    static let reachNoticeHoldSeconds = 20.0

    func updateCollectionReach(session: inout RunSession, deltaSeconds: Double) -> [RunEffect] {
        guard session.mode == .adaptive,
            session.rhythmControl.mode == .automatic,
            let target = session.autoTargetState.settledTargetSPM,
            let condition = collectionReach(at: target)
        else {
            session.collectionReach.condition = nil
            session.collectionReach.heldSeconds = 0
            return []
        }

        if session.collectionReach.condition == condition {
            session.collectionReach.heldSeconds += max(deltaSeconds, 0)
        } else {
            session.collectionReach.condition = condition
            session.collectionReach.heldSeconds = max(deltaSeconds, 0)
        }
        guard session.collectionReach.heldSeconds >= Self.reachNoticeHoldSeconds,
            !session.collectionReach.noticed.contains(condition)
        else { return [] }
        session.collectionReach.noticed.append(condition)
        return [.showReachNotice(condition)]
    }

    // Nil when enough of the collection reaches the target. Otherwise the direction most of the
    // unreachable songs miss in: faster than the body, or slower.
    func collectionReach(at targetSPM: Double) -> CollectionReach? {
        let ready = tracks.filter(\.isAdaptiveReady)
        guard !ready.isEmpty else { return nil }
        let planner = TrackMatchPlanner()
        var reachable = 0
        var faster = 0
        var slower = 0
        for track in ready {
            if planner.fit(of: track, requestedBPM: targetSPM) != nil {
                reachable += 1
            } else if let nearest = planner.nearestAchievableCadenceBPM(for: track, requestedBPM: targetSPM) {
                if nearest > targetSPM { faster += 1 } else { slower += 1 }
            }
        }
        guard Double(reachable) < Double(ready.count) * Self.reachableShareFloor else { return nil }
        return faster >= slower ? .mostlyFaster : .mostlySlower
    }
}
