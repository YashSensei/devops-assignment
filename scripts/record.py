"""Run a command and retain authentic output, exit status and revision metadata."""
import argparse
import datetime
import json
from pathlib import Path
import platform
import subprocess
import sys

parser = argparse.ArgumentParser()
parser.add_argument("label")
parser.add_argument("--cwd", default=".")
parser.add_argument("command", nargs=argparse.REMAINDER)
args = parser.parse_args()
command = args.command[1:] if args.command and args.command[0] == "--" else args.command
if not command:
    parser.error("Supply a command after --")
root = Path(__file__).resolve().parent.parent
now = datetime.datetime.now(datetime.timezone.utc)
revision = subprocess.run(["git", "rev-parse", "HEAD"], cwd=root, capture_output=True, text=True).stdout.strip()
dirty = subprocess.run(["git", "status", "--porcelain"], cwd=root, capture_output=True, text=True).stdout.strip()
result = subprocess.run(command, cwd=args.cwd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                        text=True, errors="replace")
destination = root / "evidence" / "runs" / (now.strftime("%Y%m%dT%H%M%S%fZ") + "-" + args.label + ".json")
destination.parent.mkdir(parents=True, exist_ok=True)
destination.write_text(json.dumps({"timestamp_utc": now.isoformat(), "revision": revision,
    "dirty": bool(dirty), "environment": platform.platform(), "cwd": str(Path(args.cwd).resolve()),
    "command": command, "exit_code": result.returncode, "output": result.stdout}, indent=2) + "\n", encoding="utf-8")
print(result.stdout)
print(f"Evidence: {destination.relative_to(root)}; exit code {result.returncode}")
sys.exit(result.returncode)
