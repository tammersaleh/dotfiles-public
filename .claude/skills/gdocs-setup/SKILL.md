---
name: gdocs-setup
description: "One-time Google Docs Apps Script setup. Run before first use of /gdocs, when Google Docs auth fails, or on 'set up Google Docs' or 'configure docs access'."
disable-model-invocation: true
allowed-tools: Bash(uv run --project .claude/skills/gdocs python .claude/skills/gdocs/scripts/setup_auth.py *), Bash(openssl rand -hex 32), Bash(chmod *), Bash(~/.claude/scripts/cdp-fetch.sh *), Bash(~/.claude/scripts/chrome-debug.sh *)
---

# Google Docs Setup

One-time setup for Google Docs access (read and write) used by the `/gdocs` skill.

## How It Works

You deploy a small Google Apps Script that acts as a bridge between Claude and your Google Docs. The script runs under your Google account and can read (and optionally write) documents. Setup takes ~5 minutes.

## Prerequisites

- A Google account (CoreWeave Workspace)
- Access to [script.google.com](https://script.google.com)
- Chrome debug instance running: `~/.claude/scripts/chrome-debug.sh start`
- Signed into Okta in the Chrome debug instance
- **If upgrading to write access**: You must create a new deployment of the Apps Script (existing deployments keep their original permissions)

## Step 1: Generate an API Key

Generate a random key to secure your Apps Script endpoint:

```bash
openssl rand -hex 32
```

Copy the output — you'll need it in Steps 2 and 4.

## Step 2: Create the Apps Script

1. Go to [script.google.com](https://script.google.com) → **New project**
2. Name the project (e.g., `gdocs-cli`)
3. Delete any default code in the editor
4. Open the file `.claude/skills/gdocs/appscript/Code.gs` in this repo and **copy its entire contents** into the Apps Script editor
5. **Replace** `REPLACE_WITH_YOUR_KEY` on line 13 with the API key from Step 1
6. Click the **Save** button (disk icon or Ctrl+S)

## Step 3: Deploy as Web App

1. Click **Deploy** → **New deployment**
2. Click the gear icon next to "Select type" → choose **Web app**
3. Settings:
   - **Description**: `gdocs-cli` (or anything)
   - **Execute as**: `Me`
   - **Who has access**: `Anyone within CoreWeave` (or `Anyone` if available)
4. Click **Deploy**
5. Click **Authorize access** → sign in → **Allow** (grants the script access to your Google Docs)
6. **Copy the Web app URL** — it looks like `https://script.google.com/a/macros/coreweave.com/s/AKfyc.../exec`

If you see "Google hasn't verified this app", click **Advanced** → **Go to gdocs-cli (unsafe)** — this is normal for personal scripts.

## Step 4: Save Credentials and Verify

Install Python dependencies (if not done):

```bash
cd .claude/skills/gdocs && uv sync
```

Ensure the Chrome debug instance is running and you're signed into Okta:

```bash
~/.claude/scripts/chrome-debug.sh start
```

Run the setup script with your URL and key:

```bash
uv run --project .claude/skills/gdocs python .claude/skills/gdocs/scripts/setup_auth.py \
  --url "YOUR_WEB_APP_URL" \
  --key "YOUR_API_KEY"
```

This verifies connectivity by sending a `ping` action via CDP. Make sure `GDOCS_APPSCRIPT_URL` and `GDOCS_APPSCRIPT_KEY` are exported as environment variables before running.

## Step 5: Verify Manually (Optional)

```bash
uv run --project .claude/skills/gdocs python .claude/skills/gdocs/scripts/documents.py get --id YOUR_TEST_DOC_ID --pretty
```

Should return JSON with the document's title and body text.

## Updating the Apps Script

If you need to update the script code:

1. Go to [script.google.com](https://script.google.com) → open your `gdocs-cli` project
2. Edit the code
3. Click **Deploy** → **Manage deployments** → click the pencil icon on your deployment
4. Change **Version** to **New version**
5. Click **Deploy**

The URL stays the same — no need to update your local credentials.

### Re-authorizing for Write Permissions

If your original deployment was read-only and you've updated `Code.gs` to include write operations (`createDocument`, `updateDocument`, `appendContent`), Google will prompt for additional permissions on the first write request. The script needs the `https://www.googleapis.com/auth/documents` scope (read **and** write access to Google Docs).

To re-authorize:
1. Open the Apps Script editor
2. Click **Run** → select any function (e.g., `handleCreateDocument`) → click **Run**
3. Google will prompt for additional permissions — click **Allow**
4. Alternatively, re-deploy the web app (step above) and authorize when prompted

## Technical Details

> This section is for troubleshooting and understanding the architecture. You don't need it for initial setup.

The Apps Script uses the built-in `DocumentApp` service to access Google Docs (read and write). It's deployed as a web app (accessible to anyone within CoreWeave). No GCP Console or API enablement is needed. The Python tools call this endpoint through the Chrome debug instance (CDP), which handles Okta SSO authentication transparently. A shared API key prevents unauthorized access.

## Troubleshooting

### Timeout or no response

- Ensure the Chrome debug instance is running: `~/.claude/scripts/chrome-debug.sh status`
- Ensure you're signed into Okta in the Chrome debug window
- The Apps Script may need a few seconds on first invocation (cold start)

### `unauthorized` error

- The `GDOCS_APPSCRIPT_KEY` env var must match the `API_KEY` constant in your Apps Script code
- Re-check both values

### `not_found` or `permission_denied` error

- The document must be accessible to the Google account that deployed the Apps Script
- Ask the document owner to share it with your CoreWeave email

### "Google hasn't verified this app"

- Click **Advanced** → **Go to gdocs-cli (unsafe)** — this is expected for personal scripts
- Only appears once during initial authorization

### "Authorization required"

- Open the Apps Script editor → **Run** any function (e.g., `doGet`) → it will prompt for permissions
- Or re-deploy and authorize when prompted

### Apps Script execution error

- Check the Apps Script execution log: in the editor, go to **Executions** (left sidebar)
- Common issues: document too large (script timeout 6 min max)

### Need to revoke access

- Go to [Google Account Permissions](https://myaccount.google.com/permissions) → find your script → **Remove Access**
