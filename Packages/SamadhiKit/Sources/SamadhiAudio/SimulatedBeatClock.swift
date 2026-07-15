import Foundation

public struct BeatClockSnapshot: Sendable, Equatable {
    public let bpm: Double
    public let anchorUptime: TimeInterval
    public let pausedPhase: Double?

    public init(bpm: Double, anchorUptime: TimeInterval, pausedPhase: Double? = nil) {
        self.bpm = bpm
        self.anchorUptime = anchorUptime
        self.pausedPhase = pausedPhase
    }

    public func phase(atUptime uptime: TimeInterval) -> Double {
        if let pausedPhase { return pausedPhase }
        let secondsPerBeat = 60 / max(bpm, 1)
        let elapsed = max(0, uptime - anchorUptime)
        return (elapsed / secondsPerBeat).truncatingRemainder(dividingBy: 1)
    }
}

public protocol BeatClockProviding: Sendable {
    func snapshot(bpm: Double, paused: Bool) -> BeatClockSnapshot
}

public struct SimulatedBeatClock: BeatClockProviding, Sendable {
    public init() {}

    public func snapshot(bpm: Double, paused: Bool) -> BeatClockSnapshot {
        let uptime = ProcessInfo.processInfo.systemUptime
        return BeatClockSnapshot(
            bpm: bpm,
            anchorUptime: uptime,
            pausedPhase: paused ? 0.18 : nil
        )
    }
}
