import Foundation

/// Chooses one catalog song for a library track from strict metadata search results.
///
/// The search already requires the same normalized title, artist, and album. The remaining
/// question is which candidate to keep when the durations tie. Apple Music lists explicit and
/// clean edits of one song with identical metadata and identical length, so a tie is the normal
/// case for rap and a lot of pop, not an ambiguity worth rejecting. The content rating breaks it.
enum CatalogMatchSelection {
    struct Candidate: Equatable, Sendable {
        enum Rating: Equatable, Sendable {
            case clean
            case explicit
        }

        var id: String
        var durationSeconds: TimeInterval
        var rating: Rating?
    }

    static let durationToleranceSeconds: TimeInterval = 3
    static let tieWindowSeconds: TimeInterval = 0.5

    /// Returns the chosen candidate id, or nil when nothing is close enough.
    static func choose(
        from candidates: [Candidate],
        trackDurationSeconds: TimeInterval,
        trackRating: Candidate.Rating?
    ) -> String? {
        struct Ranked {
            var candidate: Candidate
            var delta: TimeInterval
        }
        var ranked: [Ranked] = []
        for candidate in candidates {
            let delta = abs(candidate.durationSeconds - trackDurationSeconds)
            if delta <= durationToleranceSeconds {
                ranked.append(Ranked(candidate: candidate, delta: delta))
            }
        }
        ranked.sort { lhs, rhs in
            if lhs.delta != rhs.delta { return lhs.delta < rhs.delta }
            return lhs.candidate.id < rhs.candidate.id
        }
        guard let best = ranked.first else { return nil }
        let tied: [Candidate] = ranked.filter { $0.delta - best.delta < tieWindowSeconds }.map(\.candidate)
        guard tied.count > 1 else { return best.candidate.id }

        if let trackRating {
            let sameRating = tied.filter { $0.rating == trackRating }
            if let match = sameRating.first { return match.id }
        }
        if let match = tied.first(where: { $0.rating == Candidate.Rating.explicit }) { return match.id }
        return tied[0].id
    }
}
