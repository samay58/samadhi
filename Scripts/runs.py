#!/usr/bin/env python3
"""Keep every Samadhi run in one place and read them.

  runs.py ingest <folder>   Add any run in a folder, one copy per run, then refresh the ledger
  runs.py read <file>       Summarize one run: build, cues, song changes, and what the phone did
  runs.py ledger            Print one line per run, oldest first, to see the trend

Runs live in ~/Documents/Samadhi Run Records/runs, or SAMADHI_RUN_ARCHIVE/runs. They are personal,
so they stay out of Git. Each run keeps its original file untouched. A later copy of the same run
replaces an earlier one only when it holds more.
"""
import collections
import csv
import json
import os
import pathlib
import shutil
import statistics
import sys

ARCHIVE = pathlib.Path(os.environ.get("SAMADHI_RUN_ARCHIVE",
                                      pathlib.Path.home() / "Documents/Samadhi Run Records"))
RUNS = ARCHIVE / "runs"
LEDGER = ARCHIVE / "ledger.csv"
THERMAL = ["nominal", "fair", "serious", "critical"]


def clock(seconds):
    seconds = int(seconds)
    return f"{seconds // 60}:{seconds % 60:02d}"


def load(path):
    """Both file shapes read the same: the older single JSON file and the current one-line-per-fact."""
    path = pathlib.Path(path)
    if path.suffix == ".json":
        run = json.loads(path.read_text())
        run.setdefault("events", [])
        run.setdefault("device", [])
        return run
    run = {"timeline": [], "events": [], "device": [], "summary": {}}
    for raw in path.read_text().splitlines():
        try:
            line = json.loads(raw)
        except json.JSONDecodeError:
            continue  # The app may have died partway through writing its last line.
        kind, body = line["line"], line["body"]
        if kind == "header":
            run.update(body)
        elif kind == "entry":
            run["timeline"].append(body)
        elif kind == "event":
            run["events"].append(body)
        elif kind == "device":
            run["device"].append(body)
        elif kind == "status":
            run.update(body)
    return run


def run_name(path):
    path = pathlib.Path(path)
    if path.suffix == ".jsonl":
        return path.name
    run = load(path)
    start = run.get("startedAt") or run.get("capturedAt", "unknown")
    return f"{start.replace(':', '-')}.json"


def is_run(path):
    if path.suffix == ".jsonl":
        return True
    if path.suffix != ".json" or path.name in ("selected-music.json", "latest-import-diagnostics.json"):
        return False
    try:
        return "timeline" in json.loads(path.read_text())
    except (json.JSONDecodeError, UnicodeDecodeError):
        return False


def ingest(folder):
    RUNS.mkdir(parents=True, exist_ok=True)
    added = []
    for path in sorted(pathlib.Path(folder).rglob("*")):
        if not path.is_file() or not is_run(path):
            continue
        destination = RUNS / run_name(path)
        if not destination.exists() or path.stat().st_size > destination.stat().st_size:
            shutil.copy2(path, destination)
            added.append(destination)
    write_ledger()
    print(f"{len(added)} new or longer, {sum(1 for _ in RUNS.iterdir())} runs kept in {RUNS}")
    return added


def facts(path):
    run = load(path)
    summary, timeline, device = run.get("summary", {}), run["timeline"], run["device"]
    kinds = collections.Counter(entry["kind"] for entry in timeline)
    latencies = [entry["commandLatencySeconds"] for entry in timeline
                 if entry["kind"] == "rateApplied" and entry.get("commandLatencySeconds") is not None]
    seconds = [entry for entry in timeline if entry["kind"] == "activeSecond"]
    errors = [abs(entry["residualTargetErrorSPM"]) for entry in seconds
              if entry.get("residualTargetErrorSPM") is not None]
    levels = [sample["context"]["batteryLevel"] for sample in device
              if sample["context"]["batteryLevel"] >= 0]
    heat = [int(sample["context"]["thermalState"]) for sample in device]
    distances = [entry["distanceMeters"] for entry in timeline if entry.get("distanceMeters") is not None]
    build = run.get("build", {})
    return {
        "run": pathlib.Path(path).stem,
        "commit": build.get("gitCommit", "")[:7],
        "schema": run.get("schemaVersion", ""),
        "state": run.get("completionState", ""),
        "playlist": run.get("collectionName", ""),
        "minutes": round(summary.get("durationSeconds", 0) / 60, 1),
        "cadence": summary.get("averageCadence") or "",
        "tempo_matched_percent": summary.get("tempoMatchedPercent") if summary.get("tempoMatchedPercent") is not None else "",
        "off_target_mean_spm": round(statistics.mean(errors), 1) if errors else "",
        "at_rate_limit_percent": round(100 * sum(1 for e in seconds if e.get("atLimit")) / len(seconds)) if seconds else "",
        "songs": summary.get("songCount", ""),
        "tempo_changes": kinds["rateApplied"],
        "reply_median_seconds": round(statistics.median(latencies), 3) if latencies else "",
        "cadence_lost": kinds["cadenceLost"],
        "cues_played": kinds["autoFeedbackDelivery"],
        "distance_km": round(max(distances) / 1000, 2) if distances else "",
        "battery_used_percent": round(100 * (levels[0] - levels[-1])) if len(levels) > 1 else "",
        "hottest": THERMAL[max(heat)] if heat else "",
    }


def rows():
    if not RUNS.exists():
        return []
    return [facts(path) for path in sorted(RUNS.iterdir(), key=lambda p: p.name)
            if path.suffix in (".json", ".jsonl")]


def write_ledger():
    table = rows()
    if not table:
        return
    with LEDGER.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(table[0]))
        writer.writeheader()
        writer.writerows(table)


def print_ledger():
    table = rows()
    if not table:
        print("No runs kept yet.")
        return
    shown = ["run", "minutes", "cadence", "tempo_matched_percent", "off_target_mean_spm",
             "at_rate_limit_percent", "tempo_changes", "cues_played", "battery_used_percent", "hottest"]
    headings = ["Started", "Min", "Steps", "Match%", "Off by", "Limit%", "Changes", "Cues", "Batt%", "Heat"]
    widths = [max(len(str(row[key])) for row in table + [dict(zip(shown, headings))]) for key in shown]
    print("  ".join(heading.ljust(width) for heading, width in zip(headings, widths)))
    for row in table:
        print("  ".join(str(row[key]).ljust(width) for key, width in zip(shown, widths)))
    print(f"\nEvery column is in {LEDGER}")


def read(path):
    run = load(path)
    timeline, summary, build = run["timeline"], run["summary"], run["build"]
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
        print(f"Record    {len(timeline)} entries, {len(run['events'])} inputs, "
              f"{len(run['device'])} phone readings, from {clock(timeline[0]['offsetSeconds'])} "
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

    if run["device"]:
        first, last = run["device"][0]["context"], run["device"][-1]["context"]
        print("\nThe phone")
        # The Simulator has no battery and reports -1.
        if first["batteryLevel"] >= 0:
            print(f"  Battery {first['batteryLevel']:.0%} to {last['batteryLevel']:.0%}")
        print(f"  Hottest {THERMAL[max(int(s['context']['thermalState']) for s in run['device'])]}")
        routes = {o["name"] for s in run["device"] for o in s["context"]["outputs"]}
        print(f"  Sound through {', '.join(sorted(routes)) or 'nothing recorded'}")
        reasons = collections.Counter(s["context"]["reason"] for s in run["device"])
        print("  " + ", ".join(f"{name} {count}" for name, count in reasons.items()))

    print("\nA played cue is the engine's word, not the hand's. Feel stays a human judgment.")


def main():
    match sys.argv[1:]:
        case ["ingest", folder]:
            ingest(folder)
        case ["read", path]:
            read(path)
        case ["ledger"]:
            print_ledger()
        case _:
            sys.exit(__doc__)


if __name__ == "__main__":
    main()
