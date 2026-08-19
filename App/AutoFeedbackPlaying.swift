import SamadhiDomain

// The reducer decides when a directional Auto cue is valid. The shell only plays what it is told
// and must never replay a cue on recovery, engine reset, or redraw.
@MainActor
protocol AutoFeedbackPlaying: AnyObject {
    func play(_ cue: AutoFeedbackCue)
    func cancel(transactionID: Int)
    func cancelAll()
    // Every handled cue reports what physically happened to it, and the haptic engine reports
    // its lifecycle, so a run record can say whether a cue played rather than only that it was sent.
    var onDelivery: ((AutoFeedbackDeliveryRecord) -> Void)? { get set }
    var onEngineEvent: ((AutoFeedbackEngineEvent) -> Void)? { get set }
}

// What became of one cue. "Played" means the engine accepted the pattern and started it; it still
// says nothing about whether a pocket could feel it.
enum AutoFeedbackDeliveryOutcome: String, Codable, Sendable {
    case playedThroughEngine
    case playedLocalSoundOnly
    case engineUnavailable
    case patternMissing
    case cancelledBeforePlay
}

struct AutoFeedbackDeliveryRecord: Equatable, Sendable {
    let transactionID: Int
    let moment: AutoFeedbackMoment
    let family: AutoFeedbackFamily
    let soundPath: AutoFeedbackSoundPath
    let outcome: AutoFeedbackDeliveryOutcome
    // Engine stop reason, error text, or which half fell back. Plain words for the record.
    let detail: String?
}

enum AutoFeedbackEngineEvent: Equatable, Sendable {
    case created
    case started
    case startFailed(String)
    case stopped(reason: String)
    case reset
    case unsupported

    var name: String {
        switch self {
        case .created: "created"
        case .started: "started"
        case .startFailed: "startFailed"
        case .stopped: "stopped"
        case .reset: "reset"
        case .unsupported: "unsupported"
        }
    }

    var detail: String? {
        switch self {
        case let .startFailed(text): text
        case let .stopped(reason): reason
        case .created, .started, .reset, .unsupported: nil
        }
    }
}
