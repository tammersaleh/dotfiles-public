#!/usr/bin/env python3
"""
Google Sheets operations tool.

Read and write spreadsheet data via Apps Script backend.

Usage:
    sheets.py info --id SPREADSHEET_ID [--pretty]             List sheets/tabs
    sheets.py read --id ID [--sheet NAME] [--range A1] [options]  Read cells
    sheets.py write --id ID --range A1 --values JSON [options]    Write cells

Examples:
    sheets.py info --id 1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgVE2upms --pretty
    sheets.py read --id ID --sheet "Sheet1" --range "A1:D10" --pretty
    sheets.py read --id ID --csv
    sheets.py write --id ID --range "A1" --values '[["Name","Score"],["Alice",95]]' --pretty
"""

import argparse
import csv
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from gdocs_client import api_call, handle_api_call


SHEET_URL_PATTERN = re.compile(r'/spreadsheets/d/([a-zA-Z0-9_-]+)')


def extract_spreadsheet_id(url: str) -> str:
    """Extract spreadsheet ID from a Google Sheets URL."""
    match = SHEET_URL_PATTERN.search(url)
    if not match:
        raise ValueError(
            f"Could not extract spreadsheet ID from URL: {url}\n"
            f"Expected format: https://docs.google.com/spreadsheets/d/<ID>/..."
        )
    return match.group(1)


def _get_sheet_id(args) -> str:
    if hasattr(args, 'url') and args.url:
        return extract_spreadsheet_id(args.url)
    return args.id


def _output(result: dict, pretty: bool):
    if pretty:
        print(json.dumps(result, indent=2))
    else:
        print(json.dumps(result))


def _output_csv(values: list):
    """Write 2D array as CSV to stdout."""
    writer = csv.writer(sys.stdout)
    for row in values:
        writer.writerow(row)


def cmd_info(args):
    """Get spreadsheet metadata and list of sheets."""
    sheet_id = _get_sheet_id(args)

    def do_info():
        return api_call('getSpreadsheet', id=sheet_id)

    result = handle_api_call(do_info)
    _output(result, args.pretty)


def cmd_read(args):
    """Read a range from a spreadsheet."""
    sheet_id = _get_sheet_id(args)

    def do_read():
        params = {'id': sheet_id}
        if args.sheet:
            params['sheet'] = args.sheet
        if args.range:
            params['range'] = args.range
        return api_call('readRange', **params)

    result = handle_api_call(do_read)

    if args.csv:
        _output_csv(result.get('values', []))
    else:
        _output(result, args.pretty)


def cmd_write(args):
    """Write values to a range."""
    sheet_id = _get_sheet_id(args)

    # Validate JSON upfront
    try:
        parsed = json.loads(args.values)
        if not isinstance(parsed, list) or not all(isinstance(r, list) for r in parsed):
            raise ValueError("Must be a 2D array")
    except (json.JSONDecodeError, ValueError) as e:
        print(json.dumps({
            "ok": False,
            "error": "invalid_values",
            "message": f"--values must be a JSON 2D array: {e}"
        }), file=sys.stderr)
        sys.exit(1)

    def do_write():
        params = {'id': sheet_id, 'range': args.range, 'values': args.values}
        if args.sheet:
            params['sheet'] = args.sheet
        return api_call('writeRange', **params)

    result = handle_api_call(do_write)
    _output(result, args.pretty)


def main():
    parser = argparse.ArgumentParser(
        description='Google Sheets operations',
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    subparsers = parser.add_subparsers(dest='command', required=True)

    # --- info ---
    info_parser = subparsers.add_parser('info', help='Get spreadsheet metadata')
    info_id = info_parser.add_mutually_exclusive_group(required=True)
    info_id.add_argument('--id', help='Google Sheets spreadsheet ID')
    info_id.add_argument('--url', help='Full Google Sheets URL')
    info_parser.add_argument('--pretty', action='store_true', help='Pretty-print JSON output')

    # --- read ---
    read_parser = subparsers.add_parser('read', help='Read cells from a spreadsheet')
    read_id = read_parser.add_mutually_exclusive_group(required=True)
    read_id.add_argument('--id', help='Google Sheets spreadsheet ID')
    read_id.add_argument('--url', help='Full Google Sheets URL')
    read_parser.add_argument('--sheet', help='Sheet/tab name (defaults to first sheet)')
    read_parser.add_argument('--range', help='A1 notation range (defaults to all data)')
    read_output = read_parser.add_mutually_exclusive_group()
    read_output.add_argument('--pretty', action='store_true', help='Pretty-print JSON output')
    read_output.add_argument('--csv', action='store_true', help='Output as CSV')

    # --- write ---
    write_parser = subparsers.add_parser('write', help='Write cells to a spreadsheet')
    write_id = write_parser.add_mutually_exclusive_group(required=True)
    write_id.add_argument('--id', help='Google Sheets spreadsheet ID')
    write_id.add_argument('--url', help='Full Google Sheets URL')
    write_parser.add_argument('--sheet', help='Sheet/tab name (defaults to first sheet)')
    write_parser.add_argument('--range', required=True, help='A1 notation for top-left cell')
    write_parser.add_argument('--values', required=True, help='JSON 2D array of values')
    write_parser.add_argument('--pretty', action='store_true', help='Pretty-print JSON output')

    args = parser.parse_args()

    try:
        if args.command == 'info':
            cmd_info(args)
        elif args.command == 'read':
            cmd_read(args)
        elif args.command == 'write':
            cmd_write(args)

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
