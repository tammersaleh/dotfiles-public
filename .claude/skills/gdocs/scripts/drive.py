#!/usr/bin/env python3
"""
Google Drive operations tool.

List files and folders via Apps Script backend.

Usage:
    drive.py ls --id FOLDER_ID [--pretty]
    drive.py ls --url FOLDER_URL [--pretty]

Examples:
    drive.py ls --id 1qxNCV1dWSE80KeUaZKwxv7WIE8RjcCSL --pretty
    drive.py ls --url "https://drive.google.com/drive/folders/1qxNCV1dWSE80KeUaZKwxv7WIE8RjcCSL" --pretty
"""

import argparse
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from gdocs_client import api_call, handle_api_call


FOLDER_URL_PATTERN = re.compile(r'/folders/([a-zA-Z0-9_-]+)')


def extract_folder_id(url: str) -> str:
    """Extract folder ID from a Google Drive folder URL."""
    match = FOLDER_URL_PATTERN.search(url)
    if not match:
        raise ValueError(
            f"Could not extract folder ID from URL: {url}\n"
            f"Expected format: https://drive.google.com/drive/folders/<ID>"
        )
    return match.group(1)


def _get_folder_id(args) -> str:
    if hasattr(args, 'url') and args.url:
        return extract_folder_id(args.url)
    return args.id


def _output(result: dict, pretty: bool):
    if pretty:
        print(json.dumps(result, indent=2))
    else:
        print(json.dumps(result))


def cmd_ls(args):
    """List files and subfolders in a Drive folder."""
    folder_id = _get_folder_id(args)

    def do_ls():
        return api_call('listFolder', id=folder_id)

    result = handle_api_call(do_ls)
    _output(result, args.pretty)


def main():
    parser = argparse.ArgumentParser(
        description='Google Drive operations',
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    subparsers = parser.add_subparsers(dest='command', required=True)

    ls_parser = subparsers.add_parser('ls', help='List files in a folder')
    ls_id = ls_parser.add_mutually_exclusive_group(required=True)
    ls_id.add_argument('--id', help='Google Drive folder ID')
    ls_id.add_argument('--url', help='Full Google Drive folder URL')
    ls_parser.add_argument('--pretty', action='store_true', help='Pretty-print JSON output')

    args = parser.parse_args()

    try:
        if args.command == 'ls':
            cmd_ls(args)

        sys.exit(0)

    except FileNotFoundError as e:
        print(json.dumps({
            "ok": False,
            "error": "credentials_not_found",
            "message": str(e)
        }), file=sys.stderr)
        sys.exit(1)

    except ValueError as e:
        print(json.dumps({
            "ok": False,
            "error": "invalid_input",
            "message": str(e)
        }), file=sys.stderr)
        sys.exit(1)

    except Exception as e:
        print(json.dumps({
            "ok": False,
            "error": "unknown",
            "message": str(e)
        }), file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
