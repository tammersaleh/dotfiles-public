#!/usr/bin/env python3
"""
Google Docs Apps Script setup verifier.

Verifies that GDOCS_APPSCRIPT_URL and GDOCS_APPSCRIPT_KEY environment
variables are set and that the Apps Script endpoint responds via CDP.

Usage:
    setup_auth.py [--url URL --key KEY]

If --url and --key are provided, they override the environment variables
for this verification run only.
"""

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path
from urllib.parse import urlencode


CDP_FETCH_SCRIPT = Path.home() / '.claude' / 'scripts' / 'cdp-fetch.sh'


def main():
    parser = argparse.ArgumentParser(
        description='Verify Google Docs Apps Script connectivity'
    )
    parser.add_argument(
        '--url',
        help='Apps Script web app URL (overrides GDOCS_APPSCRIPT_URL env var)'
    )
    parser.add_argument(
        '--key',
        help='API key (overrides GDOCS_APPSCRIPT_KEY env var)'
    )

    args = parser.parse_args()

    url = args.url or os.environ.get('GDOCS_APPSCRIPT_URL')
    key = args.key or os.environ.get('GDOCS_APPSCRIPT_KEY')

    if not url:
        print(json.dumps({
            "ok": False,
            "error": "missing_url",
            "message": "GDOCS_APPSCRIPT_URL not set. Export it or pass --url.",
        }), file=sys.stderr)
        sys.exit(1)

    if not key:
        print(json.dumps({
            "ok": False,
            "error": "missing_key",
            "message": "GDOCS_APPSCRIPT_KEY not set. Export it or pass --key.",
        }), file=sys.stderr)
        sys.exit(1)

    if not url.startswith('https://script.google.com/'):
        print(json.dumps({
            "ok": False,
            "error": "invalid_url",
            "message": f"URL must start with https://script.google.com/, got: {url[:50]}..."
        }), file=sys.stderr)
        sys.exit(1)

    if not CDP_FETCH_SCRIPT.exists():
        print(json.dumps({
            "ok": False,
            "error": "missing_script",
            "message": f"CDP fetch script not found at {CDP_FETCH_SCRIPT}.",
        }), file=sys.stderr)
        sys.exit(1)

    test_url = f"{url}?{urlencode({'key': key, 'action': 'ping'})}"

    try:
        result = subprocess.run(
            [str(CDP_FETCH_SCRIPT), test_url],
            capture_output=True,
            text=True,
            timeout=90,
            cwd=CDP_FETCH_SCRIPT.parent.parent
        )

        if result.returncode != 0:
            stderr = result.stderr.strip()
            if 'not running' in stderr:
                print(json.dumps({
                    "ok": False,
                    "error": "chrome_not_running",
                    "message": "Chrome debug instance not running. "
                               "Start it with: ~/.claude/scripts/chrome-debug.sh start",
                }), file=sys.stderr)
                sys.exit(1)

            print(json.dumps({
                "ok": False,
                "error": "verification_failed",
                "message": f"Verification failed: {stderr}",
            }), file=sys.stderr)
            sys.exit(1)

        body = result.stdout.strip()
        data = json.loads(body)

        if not data.get('ok'):
            error = data.get('error', 'unknown')
            message = data.get('message', 'Unknown error')
            print(json.dumps({
                "ok": False,
                "error": error,
                "message": f"Apps Script returned error: {message}. Check your URL and API key.",
            }), file=sys.stderr)
            sys.exit(1)

        print(json.dumps({
            "ok": True,
            "message": "Google Docs Apps Script verification successful",
        }, indent=2))

        print("\nAdd these to your shell profile:\n", file=sys.stderr)
        print(f'export GDOCS_APPSCRIPT_URL="{url}"', file=sys.stderr)
        print(f'export GDOCS_APPSCRIPT_KEY="{key}"', file=sys.stderr)

        sys.exit(0)

    except subprocess.TimeoutExpired:
        print(json.dumps({
            "ok": False,
            "error": "timeout",
            "message": "Verification timed out. "
                       "Ensure you are signed into Okta in the Chrome debug instance.",
        }), file=sys.stderr)
        sys.exit(1)

    except Exception as e:
        print(json.dumps({
            "ok": False,
            "error": "setup_failed",
            "message": f"Verification failed: {e}",
        }), file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
