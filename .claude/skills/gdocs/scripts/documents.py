#!/usr/bin/env python3
"""
Google Docs document operations tool.

Read, create, update, and append to documents via Apps Script backend.

Usage:
    documents.py get --id DOCUMENT_ID [options]                        Get a document
    documents.py create --title TITLE [--content TEXT] [options]       Create a document
    documents.py update --id ID --content TEXT [options]               Replace content
    documents.py append --id ID --content TEXT [options]               Append content

Examples:
    documents.py get --id 1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgVE2upms
    documents.py create --title "Meeting Notes" --content "# Agenda\\n\\n- Item 1" --format markdown
    documents.py update --id DOC_ID --file notes.md --format markdown
    documents.py append --id DOC_ID --content "Action items..." --separator
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path

# Add current directory to path to import gdocs_client
sys.path.insert(0, str(Path(__file__).parent))

from gdocs_client import api_call, api_call_chunked, handle_api_call
from render import doc_response_to_markdown

SKILL_NAME = "gdocs"


def _log_event(action, action_type, target_type="", target_id="", customer=""):
    """Log a TSM-AI usage event. Best-effort, never raises."""
    try:
        import json as _json
        from datetime import datetime as _dt, timezone as _tz
        from pathlib import Path as _Path
        events_dir = _Path.home() / ".claude" / "events"
        events_dir.mkdir(parents=True, exist_ok=True)
        now = _dt.now(_tz.utc)
        atlassian_email = os.environ.get("ATLASSIAN_EMAIL", "")
        tsm = atlassian_email.split("@")[0] if atlassian_email else os.environ.get("USER", "unknown")
        event = {
            "timestamp": now.isoformat(), "tsm": tsm, "skill": SKILL_NAME,
            "action": action, "action_type": action_type,
            "target_type": target_type, "target_id": str(target_id),
            "customer": customer, "source": "realtime", "metadata": {},
        }
        with open(events_dir / (now.strftime("%Y-%m") + ".jsonl"), "a") as f:
            f.write(_json.dumps(event) + "\n")
    except Exception:
        pass


# Pattern to extract document ID from a Google Docs URL
DOC_URL_PATTERN = re.compile(r'/document/d/([a-zA-Z0-9_-]+)')


def extract_doc_id(url: str) -> str:
    """Extract the document ID from a Google Docs URL."""
    match = DOC_URL_PATTERN.search(url)
    if not match:
        raise ValueError(
            f"Could not extract document ID from URL: {url}\n"
            f"Expected format: https://docs.google.com/document/d/<ID>/..."
        )
    return match.group(1)


def _get_content(args) -> str:
    """Extract content from --content or --file args."""
    if hasattr(args, 'file') and args.file:
        if args.file == '-':
            return sys.stdin.read()
        path = Path(args.file)
        if not path.exists():
            raise FileNotFoundError(f"File not found: {args.file}")
        return path.read_text()
    elif hasattr(args, 'content') and args.content:
        # Decode common escape sequences so --content "line1\nline2" produces actual newlines
        return args.content.replace('\\n', '\n').replace('\\t', '\t')
    return ''


def _get_doc_id(args) -> str:
    """Extract document ID from --id or --url args."""
    if hasattr(args, 'url') and args.url:
        return extract_doc_id(args.url)
    return args.id


def _output(result: dict, pretty: bool):
    """Print result as JSON."""
    if pretty:
        print(json.dumps(result, indent=2))
    else:
        print(json.dumps(result))


# ---------------------------------------------------------------------------
# Command handlers
# ---------------------------------------------------------------------------

def cmd_get(args):
    """Get a document by ID or URL."""
    doc_id = _get_doc_id(args)

    def do_get():
        return api_call('getDocument', id=doc_id)

    result = handle_api_call(do_get)
    _log_event("get_document", "read", "gdocs_document", target_id=doc_id)

    if args.markdown:
        print(doc_response_to_markdown(result))
    else:
        _output(result, args.pretty)


def cmd_create(args):
    """Create a new document."""
    content = _get_content(args)
    fmt = args.format or 'plain'

    def do_create():
        params = {'title': args.title, 'format': fmt}
        if content:
            return api_call_chunked('createDocument', content, **params)
        else:
            return api_call('createDocument', **params)

    result = handle_api_call(do_create)
    _log_event("create_document", "write", "gdocs_document")
    _output(result, args.pretty)


def cmd_update(args):
    """Replace a document's content."""
    doc_id = _get_doc_id(args)
    content = _get_content(args)
    fmt = args.format or 'plain'

    if not content:
        print(json.dumps({
            "ok": False,
            "error": "missing_param",
            "message": "Content is required for update. Use --content or --file."
        }), file=sys.stderr)
        sys.exit(1)

    def do_update():
        return api_call_chunked('updateDocument', content, id=doc_id, format=fmt)

    result = handle_api_call(do_update)
    _log_event("update_document", "write", "gdocs_document", target_id=doc_id)
    _output(result, args.pretty)


def cmd_comments(args):
    """List comments on a document."""
    doc_id = _get_doc_id(args)
    include_resolved = 'true' if args.include_resolved else 'false'

    def do_comments():
        return api_call('getComments', id=doc_id, includeResolved=include_resolved)

    result = handle_api_call(do_comments)
    _log_event("list_comments", "read", "gdocs_document", target_id=doc_id)
    _output(result, args.pretty)


def cmd_comment(args):
    """Add a comment to a document."""
    doc_id = _get_doc_id(args)

    def do_comment():
        return api_call('addComment', id=doc_id, content=args.content)

    result = handle_api_call(do_comment)
    _log_event("add_comment", "write", "gdocs_document", target_id=doc_id)
    _output(result, args.pretty)


def cmd_resolve_comment(args):
    """Resolve a comment on a document."""
    doc_id = _get_doc_id(args)

    def do_resolve():
        return api_call('resolveComment', id=doc_id, commentId=args.comment_id)

    result = handle_api_call(do_resolve)
    _log_event("resolve_comment", "write", "gdocs_document", target_id=doc_id)
    _output(result, args.pretty)


def cmd_append(args):
    """Append content to an existing document."""
    doc_id = _get_doc_id(args)
    content = _get_content(args)
    fmt = args.format or 'plain'
    separator = 'true' if args.separator else 'false'

    if not content:
        print(json.dumps({
            "ok": False,
            "error": "missing_param",
            "message": "Content is required for append. Use --content or --file."
        }), file=sys.stderr)
        sys.exit(1)

    def do_append():
        return api_call_chunked('appendContent', content, id=doc_id, format=fmt, separator=separator)

    result = handle_api_call(do_append)
    _log_event("append_document", "write", "gdocs_document", target_id=doc_id)
    _output(result, args.pretty)


# ---------------------------------------------------------------------------
# CLI definition
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description='Google Docs document operations',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Google Docs URL format:
  https://docs.google.com/document/d/<DOCUMENT_ID>/edit

The --url flag extracts the document ID automatically.
        """
    )

    subparsers = parser.add_subparsers(dest='command', required=True)

    # --- get ---
    get_parser = subparsers.add_parser('get', help='Get a document by ID or URL')
    get_id = get_parser.add_mutually_exclusive_group(required=True)
    get_id.add_argument('--id', help='Google Doc document ID')
    get_id.add_argument('--url', help='Full Google Docs URL')
    get_output = get_parser.add_mutually_exclusive_group()
    get_output.add_argument('--pretty', action='store_true', help='Pretty-print JSON output')
    get_output.add_argument('--markdown', action='store_true', help='Output document as Markdown')

    # --- create ---
    create_parser = subparsers.add_parser('create', help='Create a new document')
    create_parser.add_argument('--title', required=True, help='Document title')
    create_content = create_parser.add_mutually_exclusive_group()
    create_content.add_argument('--content', help='Document body content (inline string)')
    create_content.add_argument('--file', help='Path to file with content (use - for stdin)')
    create_parser.add_argument('--format', choices=['plain', 'markdown'], default='plain',
                               help='Content format (default: plain)')
    create_parser.add_argument('--pretty', action='store_true', help='Pretty-print JSON output')

    # --- update ---
    update_parser = subparsers.add_parser('update', help='Replace a document\'s content')
    update_id = update_parser.add_mutually_exclusive_group(required=True)
    update_id.add_argument('--id', help='Google Doc document ID')
    update_id.add_argument('--url', help='Full Google Docs URL')
    update_content = update_parser.add_mutually_exclusive_group(required=True)
    update_content.add_argument('--content', help='New content (replaces everything)')
    update_content.add_argument('--file', help='Path to file with content (use - for stdin)')
    update_parser.add_argument('--format', choices=['plain', 'markdown'], default='plain',
                               help='Content format (default: plain)')
    update_parser.add_argument('--pretty', action='store_true', help='Pretty-print JSON output')

    # --- append ---
    append_parser = subparsers.add_parser('append', help='Append content to a document')
    append_id = append_parser.add_mutually_exclusive_group(required=True)
    append_id.add_argument('--id', help='Google Doc document ID')
    append_id.add_argument('--url', help='Full Google Docs URL')
    append_content = append_parser.add_mutually_exclusive_group(required=True)
    append_content.add_argument('--content', help='Content to append')
    append_content.add_argument('--file', help='Path to file with content (use - for stdin)')
    append_parser.add_argument('--format', choices=['plain', 'markdown'], default='plain',
                               help='Content format (default: plain)')
    append_parser.add_argument('--separator', action='store_true',
                               help='Insert a horizontal rule before the appended content')
    append_parser.add_argument('--pretty', action='store_true', help='Pretty-print JSON output')

    # --- comments (list) ---
    comments_parser = subparsers.add_parser('comments', help='List comments on a document')
    comments_id = comments_parser.add_mutually_exclusive_group(required=True)
    comments_id.add_argument('--id', help='Google Doc document ID')
    comments_id.add_argument('--url', help='Full Google Docs URL')
    comments_parser.add_argument('--include-resolved', action='store_true',
                                 help='Include resolved comments (default: unresolved only)')
    comments_parser.add_argument('--pretty', action='store_true', help='Pretty-print JSON output')

    # --- comment (add) ---
    comment_parser = subparsers.add_parser('comment', help='Add a comment to a document')
    comment_id = comment_parser.add_mutually_exclusive_group(required=True)
    comment_id.add_argument('--id', help='Google Doc document ID')
    comment_id.add_argument('--url', help='Full Google Docs URL')
    comment_parser.add_argument('--content', required=True, help='Comment text')
    comment_parser.add_argument('--pretty', action='store_true', help='Pretty-print JSON output')

    # --- resolve-comment ---
    resolve_parser = subparsers.add_parser('resolve-comment', help='Resolve a comment')
    resolve_id = resolve_parser.add_mutually_exclusive_group(required=True)
    resolve_id.add_argument('--id', help='Google Doc document ID')
    resolve_id.add_argument('--url', help='Full Google Docs URL')
    resolve_parser.add_argument('--comment-id', required=True, help='Comment ID to resolve')
    resolve_parser.add_argument('--pretty', action='store_true', help='Pretty-print JSON output')

    args = parser.parse_args()

    try:
        if args.command == 'get':
            cmd_get(args)
        elif args.command == 'create':
            cmd_create(args)
        elif args.command == 'update':
            cmd_update(args)
        elif args.command == 'append':
            cmd_append(args)
        elif args.command == 'comments':
            cmd_comments(args)
        elif args.command == 'comment':
            cmd_comment(args)
        elif args.command == 'resolve-comment':
            cmd_resolve_comment(args)

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
