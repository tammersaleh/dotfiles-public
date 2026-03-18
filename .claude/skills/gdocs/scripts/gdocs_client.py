#!/usr/bin/env python3
"""
Google Docs Apps Script client with CDP-based authentication.

Routes requests through the Chrome debug instance via CDP to handle
Okta SSO transparently. Provides api_call() for making requests,
api_call_chunked() for large-content writes with automatic chunking,
and handle_api_call() for automatic retry on transient errors.
"""

import json
import os
import subprocess
from pathlib import Path
from typing import Any, Callable
from urllib.parse import urlencode


CDP_FETCH_SCRIPT = Path.home() / '.claude' / 'scripts' / 'cdp-fetch.sh'


def get_session() -> tuple:
    """
    Load Apps Script URL and API key from environment variables.

    Returns:
        Tuple of (base_url, api_key)

    Raises:
        FileNotFoundError: If credentials are missing
        ValueError: If credentials are empty or malformed
    """
    url = os.environ.get('GDOCS_APPSCRIPT_URL')
    key = os.environ.get('GDOCS_APPSCRIPT_KEY')

    if not url:
        raise FileNotFoundError(
            "GDOCS_APPSCRIPT_URL not set. Run /gdocs-setup first."
        )
    if not key:
        raise FileNotFoundError(
            "GDOCS_APPSCRIPT_KEY not set. Run /gdocs-setup first."
        )

    if not url.startswith('https://script.google.com/'):
        raise ValueError(
            f"Invalid Apps Script URL format. Expected https://script.google.com/..., "
            f"got: {url[:50]}..."
        )

    return url, key


def api_call(action: str, **params) -> dict:
    """
    Make an authenticated request to the Google Docs Apps Script web app via CDP.

    Routes the request through the Chrome debug instance so Okta SSO
    is handled transparently by the browser.

    Args:
        action: The action to perform (getDocument, getDocumentByUrl, ping)
        **params: Additional query parameters

    Returns:
        Parsed JSON response dict

    Raises:
        FileNotFoundError: If credential files don't exist
        RuntimeError: If CDP fetch fails
        Exception: If the Apps Script returns an error
    """
    url, key = get_session()

    query_params = {
        'key': key,
        'action': action,
    }
    query_params.update(params)

    full_url = f"{url}?{urlencode(query_params)}"

    if not CDP_FETCH_SCRIPT.exists():
        raise RuntimeError(
            f"CDP fetch script not found at {CDP_FETCH_SCRIPT}. "
            f"Ensure ~/.claude/scripts/cdp-fetch.sh exists."
        )

    result = subprocess.run(
        [str(CDP_FETCH_SCRIPT), full_url],
        capture_output=True,
        text=True,
        timeout=90,
        cwd=CDP_FETCH_SCRIPT.parent.parent  # Run from project root
    )

    if result.returncode != 0:
        stderr = result.stderr.strip()
        if 'not running' in stderr:
            raise RuntimeError(
                f"Chrome debug instance not running. "
                f"Start it with: ~/.claude/scripts/chrome-debug.sh start"
            )
        if 'Timeout' in stderr:
            raise RuntimeError(
                f"Timed out waiting for Apps Script response. "
                f"Ensure you are signed into Okta in the Chrome debug instance."
            )
        raise RuntimeError(f"CDP fetch failed: {stderr}")

    body = result.stdout.strip()
    if not body:
        raise RuntimeError("CDP fetch returned empty response.")

    data = json.loads(body)

    if not data.get('ok', False):
        error = data.get('error', 'unknown')
        message = data.get('message', 'Unknown error')
        raise Exception(f"Google Docs Apps Script error: {error} - {message}")

    return data


def handle_api_call(api_func: Callable, *args, max_retries: int = 1, **kwargs) -> Any:
    """
    Wrapper for API calls with retry on transient errors.

    Args:
        api_func: The function to call
        max_retries: Number of retry attempts (default 1)
        *args, **kwargs: Arguments to pass to api_func

    Returns:
        Result from api_func

    Raises:
        Exception: If API call fails after retries
    """
    retry_count = 0

    while True:
        try:
            result = api_func(*args, **kwargs)
            return result

        except RuntimeError as e:
            # CDP/Chrome errors — retry once in case of transient issue
            if retry_count < max_retries and any(
                keyword in str(e).lower()
                for keyword in ['timeout', 'websocket']
            ):
                retry_count += 1
                continue
            raise

        except Exception as e:
            if retry_count < max_retries and any(
                keyword in str(e).lower()
                for keyword in ['timeout', 'connection', 'temporary']
            ):
                retry_count += 1
                continue
            raise


# Content length threshold for URL parameter safety.
# After URL-encoding, content roughly doubles in size. Keeping raw content
# under 5000 chars keeps the full URL well within the ~8KB limit.
MAX_CONTENT_LENGTH = 5000


def _chunk_content(content: str, chunk_size: int, fmt: str) -> list[str]:
    """
    Split content into chunks that fit within URL length limits.

    For markdown: splits on double-newline (paragraph boundaries) to avoid
    breaking structure. For plain text: splits on single-newline (line boundaries).

    Args:
        content: The full content string
        chunk_size: Max characters per chunk
        fmt: Content format ('plain' or 'markdown')

    Returns:
        List of content chunks
    """
    if len(content) <= chunk_size:
        return [content]

    if fmt == 'markdown':
        # Split on paragraph boundaries (double newlines)
        paragraphs = content.split('\n\n')
        chunks = []
        current = ''
        for para in paragraphs:
            candidate = (current + '\n\n' + para).strip() if current else para
            if len(candidate) > chunk_size and current:
                chunks.append(current)
                current = para
            else:
                current = candidate
        if current:
            chunks.append(current)
        return chunks if chunks else [content]
    else:
        # Plain text: split on line boundaries
        lines = content.split('\n')
        chunks = []
        current = ''
        for line in lines:
            candidate = (current + '\n' + line) if current else line
            if len(candidate) > chunk_size and current:
                chunks.append(current)
                current = line
            else:
                current = candidate
        if current:
            chunks.append(current)
        return chunks if chunks else [content]


def api_call_chunked(action: str, content: str, chunk_size: int = MAX_CONTENT_LENGTH, **params) -> dict:
    """
    Make an API call, automatically chunking content if it exceeds URL length limits.

    For create: sends first chunk with createDocument, remaining via appendContent.
    For update: sends first chunk with updateDocument, remaining via appendContent.
    For append: sends all chunks via appendContent.

    Only the first chunk uses the original format (plain/markdown). Continuation
    chunks use 'plain' to avoid re-parsing partial markdown.

    Args:
        action: The action (createDocument, updateDocument, appendContent)
        content: The full content string
        chunk_size: Max characters per request (default MAX_CONTENT_LENGTH)
        **params: Additional parameters (id, title, format, etc.)

    Returns:
        Final API response dict (includes the document ID, title, body, url)
    """
    fmt = params.get('format', 'plain')
    chunks = _chunk_content(content, chunk_size, fmt)

    if len(chunks) == 1:
        return api_call(action, content=content, **params)

    # First chunk goes with the primary action
    result = api_call(action, content=chunks[0], **params)
    doc_id = result.get('id')

    if not doc_id:
        return result  # Error case — no doc ID returned

    # Remaining chunks appended as plain text
    for chunk in chunks[1:]:
        result = api_call('appendContent', id=doc_id, content=chunk, format='plain')

    return result
