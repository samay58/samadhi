import Foundation
@preconcurrency import MusicKit

@MainActor
struct AppleMusicCatalogResolver {
    func resolve(_ track: Track) async throws -> Song? {
        if let isrc = track.isrc, !isrc.isEmpty {
            var request = MusicCatalogResourceRequest<Song>(matching: \.isrc, equalTo: isrc)
            request.limit = 1
            if #available(iOS 26.4, *) {
                request.options = [.findEquivalents]
            }
            if let song = try await request.response().items.first {
                return song
            }
        }

        if #available(iOS 26.4, *),
            track.id.rawValue.allSatisfy(\.isNumber)
        {
            var request = MusicCatalogResourceRequest<Song>(
                matching: \.id,
                equalTo: track.id
            )
            request.limit = 1
            request.options = [.findEquivalents]
            if let song = try await request.response().items.first {
                return song
            }
        }

        return try await strictMetadataMatch(for: track)
    }

    private func strictMetadataMatch(for track: Track) async throws -> Song? {
        guard let duration = track.duration,
            let album = track.albumTitle,
            !album.isEmpty
        else { return nil }

        var request = MusicCatalogSearchRequest(
            term: [track.title, track.artistName, album].joined(separator: " "),
            types: [Song.self]
        )
        request.limit = 25
        let response = try await request.response()
        let matches = response.songs.compactMap { song -> (Song, TimeInterval)? in
            guard textMatches(song.title, track.title),
                textMatches(song.artistName, track.artistName),
                textMatches(song.albumTitle ?? "", album),
                let songDuration = song.duration
            else { return nil }
            let delta = abs(songDuration - duration)
            return delta <= 3 ? (song, delta) : nil
        }
        .sorted { $0.1 < $1.1 }

        guard let best = matches.first else { return nil }
        if matches.count > 1, matches[1].1 - best.1 < 0.5 {
            return nil
        }
        return best.0
    }

    private func textMatches(_ lhs: String, _ rhs: String) -> Bool {
        normalized(lhs) == normalized(rhs)
    }

    private func normalized(_ value: String) -> String {
        value.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }
}
