#!/usr/bin/env python3
"""Slack "Save for Later" items CLI.

Lists saved items from Slack's internal saved.list API, with optional
message text enrichment via conversations.history.

Usage:
    saved_items.py list [--limit N] [--include-completed] [--pretty]
    saved_items.py list --enrich [--limit N] [--include-completed] [--pretty]
    saved_items.py counts [--pretty]
    saved_items.py auth-test [--pretty]
"""

import argparse
import asyncio
import os
import sys
from datetime import datetime, timezone

sys.path.insert(0, os.path.dirname(__file__))

import httpx

from slack_client import (
    SLACK_API_BASE,
    get_credentials,
    get_auth_identity,
    make_request_json_body,
    output_json,
)

CONCURRENCY = 10


def fetch_saved_items(count=100, include_completed=False, creds=None):
    """Fetch saved items, paginating through all results up to count."""
    items = []
    cursor = None
    counts = {}

    while len(items) < count:
        page_size = min(100, count - len(items))
        payload = {"count": page_size}
        if include_completed:
            payload["include_completed"] = True
        if cursor:
            payload["cursor"] = cursor

        data = make_request_json_body("saved.list", payload=payload, creds=creds)
        page = data.get("saved_items", [])
        items.extend(page)
        counts = data.get("counts", {})

        cursor = data.get("response_metadata", {}).get("next_cursor")
        if not cursor or not page:
            break

    return items[:count], counts


def format_ts(epoch):
    """Convert epoch timestamp to human-readable string."""
    if not epoch:
        return None
    return datetime.fromtimestamp(epoch, tz=timezone.utc).strftime("%Y-%m-%d %H:%M UTC")


def build_permalink(channel_id, message_ts):
    """Build a Slack deep link for a message."""
    ts_no_dot = message_ts.replace(".", "")
    return f"https://slack.com/archives/{channel_id}/p{ts_no_dot}"


async def _enrich_items(items, creds):
    """Fetch message text and channel name for each saved item concurrently."""
    semaphore = asyncio.Semaphore(CONCURRENCY)
    headers = {
        "Authorization": f"Bearer {creds['xoxc']}",
        "Cookie": f"d={creds['xoxd']}",
        "User-Agent": creds["user_agent"],
        "Content-Type": "application/x-www-form-urlencoded",
    }

    results = {}

    async def fetch_one(client, item):
        channel = item["item_id"]
        ts = item["ts"]
        key = f"{channel}:{ts}"

        async with semaphore:
            # Fetch message
            body = {
                "token": creds["xoxc"],
                "channel": channel,
                "latest": ts,
                "inclusive": "true",
                "limit": "1",
            }
            try:
                resp = await client.post(
                    f"{SLACK_API_BASE}/conversations.history",
                    data=body,
                    headers=headers,
                )
                if resp.status_code == 429:
                    retry = int(resp.headers.get("Retry-After", "3"))
                    await asyncio.sleep(retry)
                    resp = await client.post(
                        f"{SLACK_API_BASE}/conversations.history",
                        data=body,
                        headers=headers,
                    )
                data = resp.json()
                msg = {}
                if data.get("ok") and data.get("messages"):
                    m = data["messages"][0]
                    msg["text"] = m.get("text", "")
                    msg["user"] = m.get("user", "")
                results[key] = msg
            except Exception:
                results[key] = {}

            # Fetch channel info for name
            info_body = {"token": creds["xoxc"], "channel": channel}
            try:
                resp2 = await client.post(
                    f"{SLACK_API_BASE}/conversations.info",
                    data=info_body,
                    headers=headers,
                )
                data2 = resp2.json()
                if data2.get("ok"):
                    ch = data2.get("channel", {})
                    results[key]["channel_name"] = ch.get("name", "")
                    results[key]["is_im"] = ch.get("is_im", False)
            except Exception:
                pass

    async with httpx.AsyncClient(timeout=30.0) as client:
        tasks = [fetch_one(client, item) for item in items]
        await asyncio.gather(*tasks)

    return results


def enrich_items(items, creds):
    """Sync wrapper for concurrent enrichment."""
    return asyncio.run(_enrich_items(items, creds))


def format_item(item, enrichment=None):
    """Format a single saved item for output."""
    channel = item["item_id"]
    ts = item["ts"]
    key = f"{channel}:{ts}"

    result = {
        "channel_id": channel,
        "message_ts": ts,
        "saved_at": format_ts(item.get("date_created")),
        "todo_state": item.get("todo_state", ""),
        "permalink": build_permalink(channel, ts),
    }

    due = item.get("date_due")
    if due:
        result["due"] = format_ts(due)

    completed = item.get("date_completed")
    if completed:
        result["completed_at"] = format_ts(completed)

    if enrichment and key in enrichment:
        e = enrichment[key]
        if e.get("channel_name"):
            result["channel_name"] = e["channel_name"]
        if e.get("is_im"):
            result["channel_name"] = f"DM ({e.get('channel_name', channel)})"
        if e.get("text"):
            text = e["text"]
            if len(text) > 300:
                text = text[:300] + "..."
            result["text"] = text
        if e.get("user"):
            result["from_user"] = e["user"]

    return result


# ---------------------------------------------------------------------------
# Subcommands
# ---------------------------------------------------------------------------


def cmd_auth_test(args):
    creds = get_credentials()
    identity = get_auth_identity(creds)
    output_json({"status": "ok", "identity": identity}, pretty=args.pretty)


def cmd_counts(args):
    creds = get_credentials()
    _, counts = fetch_saved_items(count=1, creds=creds)
    output_json({"status": "ok", "counts": counts}, pretty=args.pretty)


def cmd_list(args):
    creds = get_credentials()
    items, counts = fetch_saved_items(
        count=args.limit,
        include_completed=args.include_completed,
        creds=creds,
    )

    enrichment = None
    if args.enrich:
        enrichment = enrich_items(items, creds)

    formatted = [format_item(item, enrichment) for item in items]

    output_json(
        {
            "status": "ok",
            "counts": counts,
            "items": formatted,
            "returned": len(formatted),
        },
        pretty=args.pretty,
    )


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def main():
    parser = argparse.ArgumentParser(description="Slack saved items")
    sub = parser.add_subparsers(dest="command", required=True)

    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("--pretty", action="store_true", help="Pretty-print JSON")

    # auth-test
    sub.add_parser("auth-test", parents=[common])

    # counts
    sub.add_parser("counts", parents=[common])

    # list
    ls = sub.add_parser("list", parents=[common])
    ls.add_argument("--limit", type=int, default=20, help="Max items to return")
    ls.add_argument("--enrich", action="store_true", help="Fetch message text and channel names")
    ls.add_argument("--include-completed", action="store_true", help="Include completed items")

    args = parser.parse_args()
    commands = {
        "auth-test": cmd_auth_test,
        "counts": cmd_counts,
        "list": cmd_list,
    }
    commands[args.command](args)


if __name__ == "__main__":
    main()
