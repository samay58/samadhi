import Foundation
import Testing

@testable import Samadhi

private typealias Candidate = CatalogMatchSelection.Candidate

@Test func explicitAndCleanEditsResolveToTheLibraryTrackRating() {
    let candidates = [
        Candidate(id: "clean", durationSeconds: 156.78, rating: .clean),
        Candidate(id: "explicit", durationSeconds: 156.78, rating: .explicit),
    ]
    #expect(
        CatalogMatchSelection.choose(from: candidates, trackDurationSeconds: 156.78, trackRating: .explicit)
            == "explicit")
    #expect(
        CatalogMatchSelection.choose(from: candidates, trackDurationSeconds: 156.78, trackRating: .clean)
            == "clean")
}

@Test func unknownLibraryRatingPrefersTheExplicitEdit() {
    let candidates = [
        Candidate(id: "clean", durationSeconds: 190.667, rating: .clean),
        Candidate(id: "explicit", durationSeconds: 190.667, rating: .explicit),
    ]
    #expect(
        CatalogMatchSelection.choose(from: candidates, trackDurationSeconds: 190.667, trackRating: nil)
            == "explicit")
}

@Test func closestDurationWinsOutsideTheTieWindow() {
    let candidates = [
        Candidate(id: "radio-edit", durationSeconds: 210, rating: .explicit),
        Candidate(id: "album", durationSeconds: 212.4, rating: .clean),
    ]
    #expect(
        CatalogMatchSelection.choose(from: candidates, trackDurationSeconds: 212.3, trackRating: .explicit)
            == "album")
}

@Test func tiedCandidatesWithoutRatingsChooseDeterministically() {
    let candidates = [
        Candidate(id: "b", durationSeconds: 200.1, rating: nil),
        Candidate(id: "a", durationSeconds: 200.2, rating: nil),
    ]
    #expect(
        CatalogMatchSelection.choose(from: candidates, trackDurationSeconds: 200, trackRating: nil) == "b")
    #expect(
        CatalogMatchSelection.choose(from: candidates.reversed(), trackDurationSeconds: 200, trackRating: nil)
            == "b")
}

@Test func nothingWithinThreeSecondsMeansNoMatch() {
    let candidates = [Candidate(id: "long", durationSeconds: 260, rating: .explicit)]
    #expect(
        CatalogMatchSelection.choose(from: candidates, trackDurationSeconds: 250, trackRating: .explicit)
            == nil)
}
