#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# ///
"""
Claude Code statusline script
Shows: directory | git:branch ±changes | model | ctx:XX%
Context percentage uses the most recent API response's usage (resets on /clear)
"""

import json
import os
import subprocess
import sys
from pathlib import Path


def get_git_info(cwd: str) -> str:
    """Get git branch and dirty file count."""
    try:
        # Check if in git repo
        subprocess.run(
            ["git", "-C", cwd, "rev-parse", "--git-dir"],
            capture_output=True,
            check=True,
        )

        # Get branch name
        result = subprocess.run(
            ["git", "-C", cwd, "--no-optional-locks", "rev-parse", "--abbrev-ref", "HEAD"],
            capture_output=True,
            text=True,
        )
        branch = result.stdout.strip()

        # Get dirty file count
        result = subprocess.run(
            ["git", "-C", cwd, "--no-optional-locks", "status", "--porcelain"],
            capture_output=True,
            text=True,
        )
        dirty_count = len([l for l in result.stdout.splitlines() if l.strip()])

        if dirty_count == 0:
            return branch
        return f"{branch} ±{dirty_count}"

    except (subprocess.CalledProcessError, FileNotFoundError):
        return ""


def get_context_from_transcript(transcript_path: str) -> int:
    """
    Parse transcript JSONL to get CURRENT context usage.
    Finds most recent valid entry and sums its token usage.
    Based on: https://codelynx.dev/posts/calculate-claude-code-context
    """
    if not transcript_path or not Path(transcript_path).exists():
        return 0

    try:
        # Read lines in reverse to find most recent valid entry
        with open(transcript_path, "r") as f:
            lines = f.readlines()

        for line in reversed(lines):
            line = line.strip()
            if not line:
                continue

            try:
                entry = json.loads(line)

                # Skip sidechain (agent) and error entries
                if entry.get("isSidechain"):
                    continue
                if entry.get("isApiErrorMessage"):
                    continue

                # Check for usage data
                usage = entry.get("message", {}).get("usage")
                if not usage:
                    continue

                # Sum all input token types (they all count toward context)
                input_tokens = usage.get("input_tokens", 0)
                cache_read = usage.get("cache_read_input_tokens", 0)
                cache_creation = usage.get("cache_creation_input_tokens", 0)

                return input_tokens + cache_read + cache_creation

            except json.JSONDecodeError:
                continue

    except Exception:
        pass

    return 0


def main():
    # Read JSON input from Claude Code
    input_data = json.load(sys.stdin)

    # Extract info
    cwd = input_data.get("workspace", {}).get("current_dir", os.getcwd())
    model = input_data.get("model", {}).get("display_name", "?")
    transcript_path = input_data.get("transcript_path", "")
    context_size = input_data.get("context_window", {}).get("context_window_size", 200000)

    # Get git info
    git_info = get_git_info(cwd)

    # Get current context usage from transcript
    total_tokens = get_context_from_transcript(transcript_path)
    context_pct = (total_tokens * 100) // context_size if context_size > 0 else 0

    # Color codes based on thresholds
    # Green < 60%, Yellow 60-79%, Red >= 80% (auto-compact imminent)
    if context_pct >= 80:
        color = "\033[31m"  # Red
    elif context_pct >= 60:
        color = "\033[33m"  # Yellow
    else:
        color = "\033[32m"  # Green
    reset = "\033[0m"

    # Format directory (replace $HOME with ~)
    home = os.environ.get("HOME", "")
    dir_display = cwd.replace(home, "~") if home else cwd

    # Build output
    parts = [dir_display]
    if git_info:
        parts.append(f"git:{git_info}")
    parts.append(model)
    parts.append(f"ctx:{color}{context_pct}%{reset}")

    print(" | ".join(parts))


if __name__ == "__main__":
    main()
