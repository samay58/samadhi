import SamadhiDomain

// The reducer decides when a directional Auto cue is valid. The shell only plays what it is told
// and must never replay a cue on recovery, engine reset, or redraw.
@MainActor
protocol AutoFeedbackPlaying: AnyObject {
    func play(_ cue: AutoFeedbackCue)
    func cancel(transactionID: Int)
    func cancelAll()
}
