import Foundation
import SamadhiDomain

// MusicKit reports that the current entry changed, never why. Samadhi claims a reason around its
// own Previous and Next commands. Everything else is judged by where the previous song was: close
// to its end is a natural boundary, anywhere else is an outside change we cannot explain.
enum TrackChangeAttribution {
    static let naturalBoundaryToleranceSeconds: TimeInterval = 10

    static func reason(
        claimed: TrackChangeReason?,
        previousPlaybackTimeSeconds: Double?,
        previousDurationSeconds: Double?
    ) -> TrackChangeReason {
        if let claimed { return claimed }
        guard let previousPlaybackTimeSeconds,
            let previousDurationSeconds,
            previousDurationSeconds > 0
        else { return .externalUnknown }
        let remainingSeconds = previousDurationSeconds - previousPlaybackTimeSeconds
        return remainingSeconds <= naturalBoundaryToleranceSeconds ? .naturalBoundary : .externalUnknown
    }
}
