import Foundation
import SamadhiDomain

// Runs a recorded walk through today's logic. Because the reducer is pure, a run's inputs rebuild it
// exactly, so this shows what the current code would have asked for, and where that differs from
// what happened. Once logic differs, later replies from the player may not match what it would have
// been answering, so treat everything after the first difference as a strong hint, not a measurement.
// Usage: swift run --package-path Packages/SamadhiKit RunReplay <file.jsonl>
@main
struct RunReplay {
    private struct Line: Decodable {
        let line: String
    }

    private struct HeaderLine: Decodable {
        struct Body: Decodable {
            let tracks: [MusicTrack]
        }
        let body: Body
    }

    private struct EventLine: Decodable {
        struct Body: Decodable {
            let offsetSeconds: Double
            let event: RunEvent
            let effects: [String]
        }
        let body: Body
    }

    static func main() throws {
        guard CommandLine.arguments.count == 2 else {
            print("Usage: RunReplay <file.jsonl>")
            exit(2)
        }
        let text = try String(contentsOfFile: CommandLine.arguments[1], encoding: .utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        var reducer: RunReducer?
        var state = RunState.ready
        var eventCount = 0
        var differenceCount = 0
        var loggedRates = 0
        var replayedRates = 0

        for raw in text.split(separator: "\n") {
            let data = Data(raw.utf8)
            switch try decoder.decode(Line.self, from: data).line {
            case "header":
                reducer = RunReducer(tracks: try decoder.decode(HeaderLine.self, from: data).body.tracks)
            case "event":
                guard let reducer else { continue }
                let logged = try decoder.decode(EventLine.self, from: data).body
                let (next, effects) = reducer.reduce(state: state, event: logged.event)
                state = next
                eventCount += 1
                let replayed = effects.map { String(describing: $0) }
                loggedRates += logged.effects.filter { $0.hasPrefix("setPlaybackRate") }.count
                replayedRates += replayed.filter { $0.hasPrefix("setPlaybackRate") }.count
                if replayed != logged.effects {
                    differenceCount += 1
                    if differenceCount <= 5 {
                        print(String(format: "%7.1f s  then: %@", logged.offsetSeconds, logged.effects.description))
                        print(String(format: "%7.1f s   now: %@", logged.offsetSeconds, replayed.description))
                    }
                }
            default:
                continue
            }
        }

        print("Replayed \(eventCount) events. \(differenceCount) asked for something different today.")
        print("Tempo changes asked for: \(loggedRates) then, \(replayedRates) now.")
    }
}
