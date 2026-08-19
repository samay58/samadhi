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

        for candidate in [track.id.rawValue, catalogID(from: track.playParameters)]
        where candidate?.allSatisfy(\.isNumber) == true {
            if let candidate, let song = try await catalogSong(id: MusicItemID(candidate)) {
                return song
            }
        }

        return try await strictMetadataMatch(for: track)
    }

    private func catalogSong(id: MusicItemID) async throws -> Song? {
        var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: id)
        request.limit = 1
        if #available(iOS 26.4, *) {
            request.options = [.findEquivalents]
        }
        return try await request.response().items.first
    }

    /// Library items expose their catalog counterpart only inside the opaque play parameters.
    /// The encoded form carries a numeric `catalogId` for library songs that came from Apple Music.
    /// When it is absent or not numeric, the caller falls through to the metadata search.
    private func catalogID(from parameters: PlayParameters?) -> String? {
        guard let parameters,
            let data = try? JSONEncoder().encode(parameters),
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }
        let value = object["catalogId"] ?? object["catalogID"]
        if let string = value as? String { return string }
        if let number = value as? NSNumber { return number.stringValue }
        return nil
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
        let songs = response.songs.filter { song in
            textMatches(song.title, track.title)
                && textMatches(song.artistName, track.artistName)
                && textMatches(song.albumTitle ?? "", album)
                && song.duration != nil
        }
        let chosenID = CatalogMatchSelection.choose(
            from: songs.map {
                CatalogMatchSelection.Candidate(
                    id: $0.id.rawValue,
                    durationSeconds: $0.duration ?? 0,
                    rating: rating($0.contentRating)
                )
            },
            trackDurationSeconds: duration,
            trackRating: rating(track.contentRating)
        )
        return songs.first { $0.id.rawValue == chosenID }
    }

    private func rating(_ value: ContentRating?) -> CatalogMatchSelection.Candidate.Rating? {
        switch value {
        case .clean: .clean
        case .explicit: .explicit
        default: nil
        }
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
