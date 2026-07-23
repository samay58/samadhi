import Foundation
import SamadhiAudio
import SamadhiDomain

private struct CorpusFixture: Codable {
    let catalogID: String
    let title: String
    let artist: String
    let referenceBPM: Double
}

private struct LookupResponse: Decodable {
    let results: [LookupTrack]
}

private struct LookupTrack: Decodable {
    let trackId: Int64
    let trackName: String
    let artistName: String
    let previewUrl: URL?
}

private struct FixtureResult: Codable {
    let catalogID: String
    let title: String
    let artist: String
    let referenceBPM: Double
    let estimatedBPM: Double?
    let alternatePulseBPM: Double?
    let runningPulseBPM: Double?
    let confidence: Double?
    let analysisVersion: Int?
    let pulseError: Double?
    let passed: Bool
    let error: String?
}

private struct CorpusReport: Codable {
    let generatedAt: Date
    let source: String
    let referenceBasis: String
    let allowedPulseError: Double
    let requiredPassCount: Int
    let passedCount: Int
    let totalCount: Int
    let passed: Bool
    let results: [FixtureResult]
}

@main
private enum TempoCorpusValidator {
    static func main() async throws {
        let outputURL = try outputURL(arguments: CommandLine.arguments)
        let fixtures = try loadFixtures()
        let analyzer = LocalTempoAnalyzer()
        var results: [FixtureResult] = []

        for fixture in fixtures {
            let result = await validate(fixture, analyzer: analyzer)
            results.append(result)
            let estimate =
                result.estimatedBPM.map {
                    $0.formatted(.number.precision(.fractionLength(2)))
                } ?? "rejected"
            writeStatus(
                "\(result.passed ? "PASS" : "FAIL") \(fixture.catalogID) \(estimate) BPM"
            )
        }

        let passedCount = results.count(where: \.passed)
        let report = CorpusReport(
            generatedAt: Date(),
            source: "Apple catalog lookup and provider-hosted preview assets",
            referenceBasis: "The exact Apple catalog title declares the reference tempo",
            allowedPulseError: 0.02,
            requiredPassCount: 10,
            passedCount: passedCount,
            totalCount: results.count,
            passed: passedCount >= 10,
            results: results
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(report).write(to: outputURL, options: .atomic)
        writeStatus("Saved \(passedCount) of \(results.count) results to \(outputURL.path())")

        if !report.passed {
            throw CorpusValidationError.gateFailed(passedCount: passedCount, total: results.count)
        }
    }

    private static func validate(
        _ fixture: CorpusFixture,
        analyzer: LocalTempoAnalyzer
    ) async -> FixtureResult {
        do {
            let track = try await lookup(fixture)
            guard track.trackName == fixture.title, track.artistName == fixture.artist else {
                throw CorpusValidationError.metadataChanged
            }
            guard let previewURL = track.previewUrl else {
                throw CorpusValidationError.previewUnavailable
            }

            let downloadedURL = try await download(previewURL)
            defer { try? FileManager.default.removeItem(at: downloadedURL) }
            guard let analysis = try await analyzer.analyze(fileURL: downloadedURL) else {
                return result(fixture, analysis: nil, error: "Analyzer rejected preview")
            }
            return result(fixture, analysis: analysis, error: nil)
        } catch {
            return result(fixture, analysis: nil, error: String(describing: error))
        }
    }

    private static func lookup(_ fixture: CorpusFixture) async throws -> LookupTrack {
        guard var components = URLComponents(string: "https://itunes.apple.com/lookup")
        else { throw CorpusValidationError.badResponse }
        components.queryItems = [
            URLQueryItem(name: "id", value: fixture.catalogID),
            URLQueryItem(name: "country", value: "US"),
        ]
        guard let url = components.url else { throw CorpusValidationError.badResponse }
        let (data, response) = try await URLSession.shared.data(from: url)
        try requireSuccess(response)
        let lookup = try JSONDecoder().decode(LookupResponse.self, from: data)
        guard let track = lookup.results.first,
            String(track.trackId) == fixture.catalogID
        else { throw CorpusValidationError.catalogTrackUnavailable }
        return track
    }

    private static func download(_ remoteURL: URL) async throws -> URL {
        let (temporaryURL, response) = try await URLSession.shared.download(from: remoteURL)
        try requireSuccess(response)
        let localURL = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString)
            .appendingPathExtension(remoteURL.pathExtension.isEmpty ? "m4a" : remoteURL.pathExtension)
        try FileManager.default.moveItem(at: temporaryURL, to: localURL)
        return localURL
    }

    private static func requireSuccess(_ response: URLResponse) throws {
        guard let response = response as? HTTPURLResponse,
            (200...299).contains(response.statusCode)
        else { throw CorpusValidationError.badResponse }
    }

    private static func result(
        _ fixture: CorpusFixture,
        analysis: TempoAnalysis?,
        error: String?
    ) -> FixtureResult {
        let pulseError = analysis.map { analysis in
            abs(analysis.baseBPM - fixture.referenceBPM) / fixture.referenceBPM
        }
        return FixtureResult(
            catalogID: fixture.catalogID,
            title: fixture.title,
            artist: fixture.artist,
            referenceBPM: fixture.referenceBPM,
            estimatedBPM: analysis?.baseBPM,
            alternatePulseBPM: analysis?.alternatePulseBPM,
            runningPulseBPM: analysis?.runningPulseBPM,
            confidence: analysis?.confidence,
            analysisVersion: analysis?.version,
            pulseError: pulseError,
            passed: pulseError.map { $0 <= 0.02 } ?? false,
            error: error
        )
    }

    private static func loadFixtures() throws -> [CorpusFixture] {
        guard let url = Bundle.module.url(forResource: "Corpus", withExtension: "json")
        else { throw CorpusValidationError.corpusUnavailable }
        return try JSONDecoder().decode([CorpusFixture].self, from: Data(contentsOf: url))
    }

    private static func outputURL(arguments: [String]) throws -> URL {
        guard let flagIndex = arguments.firstIndex(of: "--output"),
            arguments.indices.contains(flagIndex + 1)
        else { throw CorpusValidationError.outputRequired }
        return URL(fileURLWithPath: arguments[flagIndex + 1])
    }

    private static func writeStatus(_ message: String) {
        FileHandle.standardError.write(Data("\(message)\n".utf8))
    }
}

private enum CorpusValidationError: Error {
    case badResponse
    case catalogTrackUnavailable
    case corpusUnavailable
    case gateFailed(passedCount: Int, total: Int)
    case metadataChanged
    case outputRequired
    case previewUnavailable
}
