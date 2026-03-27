#!/usr/bin/env python3
"""
Positional document editing via the Docs REST API proxy.

Supports inserting text after a heading, which the convenience API cannot do.
Uses docsGet for raw document reads and docsBatchUpdate for writes.

Usage:
    docedit.py insert-after-heading --id DOC_ID --heading "NEXT" --text "- Item\\n"
    docedit.py insert-after-heading --id DOC_ID --heading "NEXT" --text "- Item\\n" --create-if-missing
    docedit.py headings --id DOC_ID --pretty
"""

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from gdocs_client import api_call, handle_api_call


def docs_get_headings(doc_id: str) -> list[dict]:
    """Get lightweight heading list with character indices."""
    result = handle_api_call(api_call, 'docsGet', id=doc_id, headingsOnly='true')
    return result.get('headings', [])


def docs_batch_update(doc_id: str, requests: list) -> dict:
    """Send batchUpdate requests to a document."""
    return handle_api_call(
        api_call, 'docsBatchUpdate',
        id=doc_id,
        requests=json.dumps(requests),
    )


def cmd_insert_after_heading(args):
    """Insert text after a specific heading."""
    headings = docs_get_headings(args.id)

    # Find the target heading
    target = None
    target_idx = None
    for i, h in enumerate(headings):
        if h['text'].upper() == args.heading.upper():
            target = h
            target_idx = i
            break

    if target is None:
        if not args.create_if_missing:
            print(json.dumps({
                'ok': False,
                'error': 'heading_not_found',
                'message': f'Heading "{args.heading}" not found in document',
            }))
            sys.exit(1)

        # Create heading before the first H2 (dated entry)
        insert_index = None
        for h in headings:
            if h['level'] == 2:
                insert_index = h['startIndex']
                break

        if insert_index is None:
            # No H2 found - put it near the start
            insert_index = headings[-1]['endIndex'] if headings else 1

        heading_text = f'\n{args.heading}\n'
        content_text = args.text if args.text.endswith('\n') else args.text + '\n'

        requests = [
            {
                'insertText': {
                    'location': {'index': insert_index},
                    'text': heading_text + content_text,
                }
            },
            {
                'updateParagraphStyle': {
                    'range': {
                        'startIndex': insert_index + 1,
                        'endIndex': insert_index + 1 + len(args.heading),
                    },
                    'paragraphStyle': {'namedStyleType': 'HEADING_2'},
                    'fields': 'namedStyleType',
                }
            },
            # Reset content after heading to normal text
            {
                'updateParagraphStyle': {
                    'range': {
                        'startIndex': insert_index + len(heading_text),
                        'endIndex': insert_index + len(heading_text) + len(content_text),
                    },
                    'paragraphStyle': {'namedStyleType': 'NORMAL_TEXT'},
                    'fields': 'namedStyleType',
                }
            },
        ]

        docs_batch_update(args.id, requests)
        print(json.dumps({'ok': True, 'action': 'created_heading_and_inserted', 'index': insert_index}))
        return

    # Heading exists - find the next heading at same or higher level
    insert_index = target['endIndex']
    for h in headings[target_idx + 1:]:
        if h['level'] <= target['level']:
            insert_index = h['startIndex']
            break

    text = args.text if args.text.endswith('\n') else args.text + '\n'

    requests = [
        {
            'insertText': {
                'location': {'index': insert_index},
                'text': text,
            }
        },
        # Reset paragraph style to normal so it doesn't inherit heading style
        {
            'updateParagraphStyle': {
                'range': {
                    'startIndex': insert_index,
                    'endIndex': insert_index + len(text),
                },
                'paragraphStyle': {'namedStyleType': 'NORMAL_TEXT'},
                'fields': 'namedStyleType',
            }
        },
    ]

    docs_batch_update(args.id, requests)
    print(json.dumps({'ok': True, 'action': 'inserted', 'index': insert_index}))


def cmd_headings(args):
    """Print heading positions for a document."""
    headings = docs_get_headings(args.id)
    if args.pretty:
        print(json.dumps(headings, indent=2))
    else:
        print(json.dumps(headings))


def main():
    parser = argparse.ArgumentParser(description='Positional document editing')
    subparsers = parser.add_subparsers(dest='command', required=True)

    # insert-after-heading
    p_insert = subparsers.add_parser('insert-after-heading',
        help='Insert text after a specific heading')
    p_insert.add_argument('--id', required=True, help='Document ID')
    p_insert.add_argument('--heading', required=True, help='Heading text to find')
    p_insert.add_argument('--text', required=True, help='Text to insert')
    p_insert.add_argument('--create-if-missing', action='store_true',
        help='Create the heading if it does not exist')
    p_insert.set_defaults(func=cmd_insert_after_heading)

    # headings
    p_hdg = subparsers.add_parser('headings', help='List heading positions')
    p_hdg.add_argument('--id', required=True, help='Document ID')
    p_hdg.add_argument('--pretty', action='store_true', help='Pretty print')
    p_hdg.set_defaults(func=cmd_headings)

    args = parser.parse_args()
    args.func(args)


if __name__ == '__main__':
    main()
