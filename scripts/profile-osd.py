#!/usr/bin/env python3
"""Measure a finite fake-audio OSD probe; never reads screen pixels or input."""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import shutil
import tempfile
import threading
import time


def process_stats(pid):
    fields = Path(f"/proc/{pid}/stat").read_text().split(") ", 1)[1].split()
    return {
        "cpu": (int(fields[11]) + int(fields[12])) / os.sysconf("SC_CLK_TCK"),
        "rss_mib": int(fields[21]) * os.sysconf("SC_PAGE_SIZE") / 1024**2,
    }


def frame_summary(log_path):
    """Qt timings are integer milliseconds, not GPU or presentation timestamps."""
    current = None
    samples = {}
    for line in log_path.read_text().splitlines():
        if "BENCH_PHASE " in line:
            current = line.split("BENCH_PHASE ", 1)[1].strip()
        if current is None:
            continue
        phase = samples.setdefault(current, {"gui": [], "render": []})
        gui = re.search(r"Frame prepared, polish=(\d+) ms, lock=\d+ ms, blockedForSync=\d+ ms, animations=(\d+) ms", line)
        render = re.search(r"frame rendered in \d+ms, sync=(\d+), render=(\d+)", line)
        if gui:
            phase["gui"].append(int(gui[1]) + int(gui[2]))
        if render:
            phase["render"].append(int(render[1]) + int(render[2]))
    def percentile(values):
        return sorted(values)[min(len(values) - 1, int(len(values) * 0.95))] if values else 0
    return {name: {"prepared_frames": len(values["gui"]),
                   "gui_ms_p95": percentile(values["gui"]),
                   "gui_ms_max": max(values["gui"], default=0),
                   "sync_render_ms_p95": percentile(values["render"])}
            for name, values in samples.items()}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=Path("src"))
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--dense", action="store_true")
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    args.output.parent.mkdir(parents=True, exist_ok=True)
    workspace = tempfile.TemporaryDirectory(prefix="dot-shell-profile-")
    probe_root = Path(workspace.name)
    shutil.copytree(args.source.resolve(), probe_root / "src")
    shutil.copytree(root / "tests/performance", probe_root / "tests/performance")
    (probe_root / "shell.qml").write_text('import "tests/performance"\nProbe {}\n')
    env = dict(os.environ, DOT_SHELL_BENCH_DENSE="1" if args.dense else "0", QSG_RENDER_TIMING="1", QSG_INFO="1")
    command = ["qs", "-p", str(probe_root / "shell.qml"), "--no-color"]
    process = subprocess.Popen(command, env=env, stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT, text=True)
    timeout = threading.Timer(60, process.terminate)
    timeout.daemon = True
    timeout.start()
    phases = {}
    current = None
    start = None
    errors = []
    try:
        with args.output.with_suffix(".log").open("w") as log:
            for line in process.stdout:
                log.write(line)
                if "WARN scene:" in line or "ERROR" in line:
                    errors.append(line.strip())
                if "BENCH_PHASE " not in line:
                    continue
                now = time.monotonic()
                stats = process_stats(process.pid)
                if current is not None:
                    elapsed = now - start[0]
                    phases[current] = {"wall_seconds": round(elapsed, 3),
                        "cpu_percent_one_core": round((stats["cpu"] - start[1]["cpu"]) / elapsed * 100, 2),
                        "rss_mib_end": round(stats["rss_mib"], 2)}
                current = line.split("BENCH_PHASE ", 1)[1].strip()
                start = (now, stats)
                print(f"Probe: {current}", flush=True)
        if process.wait() != 0 or "dormant" not in phases or errors:
            raise SystemExit(f"Probe failed; inspect {args.output.with_suffix('.log')}")
    finally:
        timeout.cancel()
        if process.poll() is None:
            process.terminate()
            process.wait(timeout=5)
        workspace.cleanup()
    timings = frame_summary(args.output.with_suffix(".log"))
    for phase, values in phases.items():
        values.update(timings.get(phase, {}))
    args.output.write_text(json.dumps({"source": str(args.source), "dense": args.dense,
                                      "phases": phases}, indent=2) + "\n")
    print(json.dumps(phases, indent=2))


if __name__ == "__main__":
    main()
