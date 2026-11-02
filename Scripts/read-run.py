#!/usr/bin/env python3
"""Summarize a Samadhi run record in plain terms.

Answers the questions a walk leaves behind: which build ran, whether cues physically played, why
each song changed, and what the record itself lost.
"""

import collections
import json
import statistics
import sys


def clock(seconds):
    whole = int(seconds or 0)
    return f"{whole // 60}:{whole % 60:02d}"


def main(path):
    with open(path) as handle:
        run = json.load(handle)

    build = run["build"]
    summary = run["summary"]
    timeline = run["timeline"]
    # The recorder omits absent values, so anything optional may be missing from the file.
    percent = summary.get("tempoMatchedPercent")
    matched = "not measured" if percent is None else f"{percent}%"
    print(f"Build     {build['gitCommit'][:7]} on {build['gitBranch']}"
          f"{', dirty' if build['trackedFilesDirty'] else ''}")
    print(f"Source    {build['sourceFingerprint']}")
    print(f"Schema    {run['schemaVersion']}, analyzer {build['tempoAnalyzerVersion']}, "
          f"{run.get('completionState', 'unknown')}")
    print(f"Music     {run['environment'].get('musicService', 'unknown')}, "
          f"motion {run['environment'].get('motionService', 'unknown')}")
    print(f"Playlist  {run['collectionName']}, {run['readyTrackCount']} ready songs")
    print(f"Length    {clock(summary['durationSeconds'])}, "
          f"average cadence {summary.get('averageCadence') or 'none'}, "
          f"tempo matched {matched} "
          f"over {summary.get('tempoMatchedCoveragePercent', 0)}% coverage")
    print(f"Control   Auto {clock(summary['automaticSeconds'])}, "
          f"Manual {clock(summary['manualSeconds'])}, {summary['songCount']} songs")

    if timeline:
        print(f"Record    {len(timeline)} entries from {clock(timeline[0]['offsetSeconds'])} "
              f"to {clock(timeline[-1]['offsetSeconds'])}")
    kinds = collections.Counter(entry["kind"] for entry in timeline)

    print("\nSong changes")
    changes = [entry for entry in timeline if entry["kind"] == "trackChanged"]
    for entry in changes:
        print(f"  {clock(entry['offsetSeconds'])}  {entry.get('trackChangeReason') or 'unknown'}"
              f"  to {entry.get('trackTitle') or entry.get('trackID') or 'unknown'}")
    if not changes:
        print("  none")

    print("\nCues the reducer sent")
    began = [entry for entry in timeline
             if entry["kind"] == "autoFeedback" and entry.get("autoFeedbackPhase")]
    phases = collections.Counter(entry["autoFeedbackPhase"] for entry in began)
    print("  " + (", ".join(f"{name} {count}" for name, count in phases.items()) or "none"))

    print("\nWhat became of them")
    outcomes = collections.Counter(entry.get("autoFeedbackDeliveryOutcome")
                                   for entry in timeline
                                   if entry["kind"] == "autoFeedbackDelivery")
    print("  " + (", ".join(f"{name} {count}" for name, count in outcomes.items()) or "none"))
    engine = collections.Counter(entry.get("hapticEngineEvent")
                                 for entry in timeline if entry["kind"] == "hapticEngine")
    print("  Engine: " + (", ".join(f"{name} {count}" for name, count in engine.items()) or "none"))

    print("\nAuto")
    rates = [entry["appliedRate"] for entry in timeline if entry["kind"] == "rateApplied"]
    if rates:
        print(f"  {len(rates)} rate replies, from {min(rates):.3f} to {max(rates):.3f}")
    else:
        print("  no rate replies")
    latencies = [entry["commandLatencySeconds"] for entry in timeline
                 if entry["kind"] == "rateApplied"
                 and entry.get("commandLatencySeconds") is not None]
    if latencies:
        print(f"  Median reply time {statistics.median(latencies):.3f} s")
    print(f"  At the rate limit in {sum(1 for entry in timeline if entry.get('atLimit'))} entries")

    print("\nBoundaries and reach")
    print(f"  Next song plans: {kinds['nextSongPlanned']}")
    for entry in timeline:
        if entry["kind"] == "nextSongPlanned":
            print(f"    {clock(entry['offsetSeconds'])}  {entry.get('nextSongOutlook')}"
                  f"  {entry.get('plannedNextTrackTitle') or ''}".rstrip())
    print(f"  Reach notices: {kinds['reachNoticed']}")

    print("\nInterruptions")
    for kind in ("paused", "routeLost", "routeRestored", "interruptionBegan",
                 "interruptionEnded", "playbackFailed"):
        if kinds[kind]:
            print(f"  {kind}: {kinds[kind]}")
    if not any(kinds[kind] for kind in ("paused", "routeLost", "interruptionBegan",
                                        "playbackFailed")):
        print("  none")

    print("\nA played cue is the engine's word, not the hand's. Feel stays a human judgment.")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("Usage: read-run.py <latest-run-diagnostics.json>")
    main(sys.argv[1])
