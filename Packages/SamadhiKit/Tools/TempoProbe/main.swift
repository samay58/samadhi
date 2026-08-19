import Foundation
import SamadhiAudio
import SamadhiDomain

// Development probe. Give it Apple catalog song identifiers; it fetches each 30-second preview
// through the public lookup service, runs the analyzer, and prints what the analyzer saw:
// the decision, the confidence, and the strongest tempo candidates. Nothing here ships.

private struct LookupResponse: Decodable {
    let results: [LookupTrack]
}

private struct LookupTrack: Decodable {
    let trackId: Int64
    let trackName: String
    let artistName: String
    let previewUrl: URL?
}

@main
private enum TempoProbe {
    static func main() async throws {
        let ids = CommandLine.arguments.dropFirst().filter { $0.allSatisfy(\.isNumber) }
        guard !ids.isEmpty else {
            FileHandle.standardError.write(Data("usage: TempoProbe <catalog id> [...]\n".utf8))
            exit(2)
        }
        let analyzer = LocalTempoAnalyzer()
        for id in ids {
            do {
                let track = try await lookup(id)
                guard let previewURL = track.previewUrl else {
                    print("\(id)\tno preview")
                    continue
                }
                let (temporaryURL, _) = try await URLSession.shared.download(from: previewURL)
                let localURL = FileManager.default.temporaryDirectory
                    .appending(path: UUID().uuidString).appendingPathExtension("m4a")
                try FileManager.default.moveItem(at: temporaryURL, to: localURL)
                defer { try? FileManager.default.removeItem(at: localURL) }
                let probe = try await analyzer.probe(fileURL: localURL)
                report(id: id, track: track, probe: probe)
            } catch {
                print("\(id)\terror \(error)")
            }
        }
    }

    private static func report(id: String, track: LookupTrack, probe: TempoEstimator.Probe) {
        let decision: String
        if let analysis = probe.analysis {
            let alternate = analysis.alternatePulseBPM.map { " alt \(format($0))" } ?? ""
            decision = "READY \(format(analysis.baseBPM))\(alternate) conf \(format(analysis.confidence))"
        } else {
            decision = "REJECTED"
        }
        let scores = probe.scores
        let peaks = localMaxima(scores).sorted { $0.correlation > $1.correlation }.prefix(6)
        let lower = scores.filter { $0.tempo < 120 }.max { $0.correlation < $1.correlation }
        let running = scores.filter { $0.tempo >= 120 }.max { $0.correlation < $1.correlation }
        print("\(id)\t\(track.trackName) | \(track.artistName)")
        print("  \(decision)")
        if let lower, let running {
            print(
                "  best <120: \(format(lower.tempo)) @ \(format(lower.correlation))   best >=120: \(format(running.tempo)) @ \(format(running.correlation))"
            )
        }
        print("  peaks: " + peaks.map { "\(format($0.tempo))@\(format($0.correlation))" }.joined(separator: "  "))
    }

    private static func localMaxima(_ scores: [(tempo: Double, correlation: Double)]) -> [(
        tempo: Double, correlation: Double
    )] {
        guard scores.count > 2 else { return scores }
        var result: [(tempo: Double, correlation: Double)] = []
        for index in 1..<(scores.count - 1)
        where scores[index].correlation >= scores[index - 1].correlation
            && scores[index].correlation > scores[index + 1].correlation
        {
            result.append(scores[index])
        }
        return result
    }

    private static func format(_ value: Double) -> String {
        String(format: "%.2f", value)
    }

    private static func lookup(_ id: String) async throws -> LookupTrack {
        guard var components = URLComponents(string: "https://itunes.apple.com/lookup") else {
            throw ProbeError.notFound
        }
        components.queryItems = [URLQueryItem(name: "id", value: id), URLQueryItem(name: "country", value: "US")]
        guard let url = components.url else { throw ProbeError.notFound }
        let (data, _) = try await URLSession.shared.data(from: url)
        let lookup = try JSONDecoder().decode(LookupResponse.self, from: data)
        guard let track = lookup.results.first else { throw ProbeError.notFound }
        return track
    }
}

private enum ProbeError: Error {
    case notFound
}
