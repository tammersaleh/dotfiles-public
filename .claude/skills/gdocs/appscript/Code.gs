/**
 * Google Docs API proxy for Claude Code.
 *
 * Deploy as a Google Apps Script web app:
 *   Execute as: Me
 *   Who has access: Anyone
 *
 * All requests must include a ?key= parameter matching API_KEY.
 * Replace the API_KEY below with a random string before deploying.
 *
 * Read operations use doGet(). Write operations also use doGet() with
 * action names that distinguish intent (CDP routing is GET-only).
 *
 * SETUP: Enable the "Google Docs API" Advanced Service in the script
 * editor (Services > + > Google Docs API > Add). This provides full
 * smart chip support (person mentions, dates, rich links). Without it,
 * reads fall back to DocumentApp which strips smart chip content.
 */

// Replace this with a random key (e.g., run: openssl rand -hex 32)
var API_KEY = 'ca0a27b4464c2333ce4ec74ac58159d74cb098825366f1ee86bdb6622ccd64fb';

function doGet(e) {
  try {
    if (!e.parameter.key || e.parameter.key !== API_KEY) {
      return jsonResponse({ ok: false, error: 'unauthorized' });
    }

    const action = e.parameter.action;

    switch (action) {
      // Read operations
      case 'getDocument':
        return handleGetDocument(e.parameter);
      case 'getDocumentByUrl':
        return handleGetDocumentByUrl(e.parameter);

      // Write operations
      case 'createDocument':
        return handleCreateDocument(e.parameter);
      case 'updateDocument':
        return handleUpdateDocument(e.parameter);
      case 'appendContent':
        return handleAppendContent(e.parameter);

      // Drive operations
      case 'listFolder':
        return handleListFolder(e.parameter);

      // Spreadsheet operations
      case 'getSpreadsheet':
        return handleGetSpreadsheet(e.parameter);
      case 'readRange':
        return handleReadRange(e.parameter);
      case 'writeRange':
        return handleWriteRange(e.parameter);

      // Comment operations
      case 'getComments':
        return handleGetComments(e.parameter);
      case 'addComment':
        return handleAddComment(e.parameter);
      case 'resolveComment':
        return handleResolveComment(e.parameter);

      // Raw API proxies - generic access without new handlers
      case 'docsGet':
        return handleDocsGet(e.parameter);
      case 'docsBatchUpdate':
        return handleDocsBatchUpdate(e.parameter);
      case 'sheetsGet':
        return handleSheetsGet(e.parameter);
      case 'sheetsBatchUpdate':
        return handleSheetsBatchUpdate(e.parameter);
      case 'sheetsValuesGet':
        return handleSheetsValuesGet(e.parameter);
      case 'sheetsValuesUpdate':
        return handleSheetsValuesUpdate(e.parameter);
      case 'driveGet':
        return handleDriveGet(e.parameter);
      case 'driveList':
        return handleDriveList(e.parameter);

      case 'ping':
        return jsonResponse({ ok: true, message: 'pong' });
      default:
        return jsonResponse({
          ok: false,
          error: 'unknown_action',
          message: 'Valid actions: getDocument, getDocumentByUrl, createDocument, updateDocument, appendContent, listFolder, getSpreadsheet, readRange, writeRange, getComments, addComment, resolveComment, ping'
        });
    }
  } catch (err) {
    if (err.isAppError) {
      return jsonResponse(err.response);
    }
    return jsonResponse({ ok: false, error: 'internal', message: err.message });
  }
}

// ---------------------------------------------------------------------------
// Raw Docs API proxy
// ---------------------------------------------------------------------------

/**
 * Return the raw Docs REST API response for a document.
 * Includes character indices for every element, enabling positional edits.
 * Params: id (Google Doc ID)
 */
function handleDocsGet(params) {
  if (!params.id) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'id is required' });
  }
  try {
    var doc = Docs.Documents.get(params.id);

    // Lightweight mode: return only heading positions with indices.
    // Use for positional edits without transferring the full document.
    if (params.headingsOnly === 'true') {
      var headings = [];
      var content = doc.body.content || [];
      for (var i = 0; i < content.length; i++) {
        var structural = content[i];
        var para = structural.paragraph;
        if (!para) continue;
        var style = (para.paragraphStyle || {}).namedStyleType || '';
        if (style.indexOf('HEADING') !== 0) continue;

        var text = '';
        var elements = para.elements || [];
        for (var j = 0; j < elements.length; j++) {
          var el = elements[j];
          if (el.textRun) text += el.textRun.content || '';
          else if (el.person) text += (el.person.personProperties || {}).name || '';
          else if (el.richLink) text += (el.richLink.richLinkProperties || {}).title || '';
          else if (el.dateElement) text += (el.dateElement.dateElementProperties || {}).displayText || '';
        }
        headings.push({
          text: text.replace(/\n$/, ''),
          level: parseInt(style.replace('HEADING_', ''), 10) || 0,
          startIndex: structural.startIndex || 0,
          endIndex: structural.endIndex || 0,
        });
      }
      return jsonResponse({ ok: true, id: doc.documentId, title: doc.title, headings: headings });
    }

    return jsonResponse({ ok: true, doc: doc });
  } catch (err) {
    return jsonResponse({ ok: false, error: 'docs_api', message: err.message });
  }
}

/**
 * Proxy arbitrary batchUpdate requests to the Docs REST API.
 * Params: id (Google Doc ID), requests (JSON array of update requests)
 *
 * Example requests param (URL-encoded JSON):
 *   [{"insertText":{"location":{"index":42},"text":"Hello\n"}}]
 *
 * See https://developers.google.com/docs/api/reference/rest/v1/documents/batchUpdate
 */
function handleDocsBatchUpdate(params) {
  if (!params.id) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'id is required' });
  }
  if (!params.requests) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'requests is required (JSON array)' });
  }
  try {
    var requests = JSON.parse(params.requests);
    var result = Docs.Documents.batchUpdate({ requests: requests }, params.id);
    return jsonResponse({ ok: true, result: result });
  } catch (err) {
    return jsonResponse({ ok: false, error: 'docs_api', message: err.message });
  }
}

// ---------------------------------------------------------------------------
// Raw Sheets API proxy
// ---------------------------------------------------------------------------

/**
 * Return the raw Sheets REST API response for a spreadsheet.
 * Params: id (Spreadsheet ID), ranges (optional, comma-separated A1 ranges),
 *         includeGridData (optional, "true" to include cell data)
 */
function handleSheetsGet(params) {
  if (!params.id) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'id is required' });
  }
  try {
    var opts = {};
    if (params.ranges) opts.ranges = params.ranges.split(',');
    if (params.includeGridData === 'true') opts.includeGridData = true;
    var sheet = Sheets.Spreadsheets.get(params.id, opts);
    return jsonResponse({ ok: true, spreadsheet: sheet });
  } catch (err) {
    return jsonResponse({ ok: false, error: 'sheets_api', message: err.message });
  }
}

/**
 * Proxy arbitrary batchUpdate requests to the Sheets REST API.
 * Params: id (Spreadsheet ID), requests (JSON array of update requests)
 */
function handleSheetsBatchUpdate(params) {
  if (!params.id) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'id is required' });
  }
  if (!params.requests) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'requests is required (JSON array)' });
  }
  try {
    var requests = JSON.parse(params.requests);
    var result = Sheets.Spreadsheets.batchUpdate({ requests: requests }, params.id);
    return jsonResponse({ ok: true, result: result });
  } catch (err) {
    return jsonResponse({ ok: false, error: 'sheets_api', message: err.message });
  }
}

/**
 * Read cell values from a spreadsheet range.
 * Params: id (Spreadsheet ID), range (A1 notation, e.g. "Sheet1!A1:C10")
 */
function handleSheetsValuesGet(params) {
  if (!params.id || !params.range) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'id and range are required' });
  }
  try {
    var result = Sheets.Spreadsheets.Values.get(params.id, params.range);
    return jsonResponse({ ok: true, values: result.values, range: result.range });
  } catch (err) {
    return jsonResponse({ ok: false, error: 'sheets_api', message: err.message });
  }
}

/**
 * Write cell values to a spreadsheet range.
 * Params: id (Spreadsheet ID), range (A1 notation), values (JSON 2D array)
 */
function handleSheetsValuesUpdate(params) {
  if (!params.id || !params.range || !params.values) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'id, range, and values are required' });
  }
  try {
    var values = JSON.parse(params.values);
    var resource = { values: values };
    var result = Sheets.Spreadsheets.Values.update(resource, params.id, params.range, {
      valueInputOption: 'USER_ENTERED',
    });
    return jsonResponse({ ok: true, updatedCells: result.updatedCells, updatedRange: result.updatedRange });
  } catch (err) {
    return jsonResponse({ ok: false, error: 'sheets_api', message: err.message });
  }
}

// ---------------------------------------------------------------------------
// Raw Drive API proxy
// ---------------------------------------------------------------------------

/**
 * Get file metadata from Drive.
 * Params: id (File ID), fields (optional, comma-separated fields)
 */
function handleDriveGet(params) {
  if (!params.id) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'id is required' });
  }
  try {
    var opts = {};
    if (params.fields) opts.fields = params.fields;
    var file = Drive.Files.get(params.id, opts);
    return jsonResponse({ ok: true, file: file });
  } catch (err) {
    return jsonResponse({ ok: false, error: 'drive_api', message: err.message });
  }
}

/**
 * List files in a Drive folder.
 * Params: folderId (Folder ID), q (optional, Drive query string),
 *         pageSize (optional, default 100), pageToken (optional)
 */
function handleDriveList(params) {
  if (!params.folderId) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'folderId is required' });
  }
  try {
    var q = params.q || ("'" + params.folderId + "' in parents and trashed = false");
    var opts = {
      q: q,
      maxResults: parseInt(params.pageSize || '100', 10),
      fields: 'items(id,title,mimeType,modifiedDate),nextPageToken',
    };
    if (params.pageToken) opts.pageToken = params.pageToken;
    var result = Drive.Files.list(opts);
    return jsonResponse({
      ok: true,
      files: result.items,
      nextPageToken: result.nextPageToken || null,
    });
  } catch (err) {
    return jsonResponse({ ok: false, error: 'drive_api', message: err.message });
  }
}

// ---------------------------------------------------------------------------
// Read handlers (convenience wrappers - use docsGet for raw access)
// ---------------------------------------------------------------------------

/**
 * Get a document by its ID.
 * Params: id (Google Doc ID)
 */
function handleGetDocument(params) {
  if (!params.id) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'id is required' });
  }

  try {
    return jsonResponse(formatDocumentFromApi(params.id));
  } catch (apiErr) {
    // Fall back to DocumentApp if Advanced Docs Service is not enabled
    var doc = openDocById(params.id);
    return jsonResponse(formatDocument(doc));
  }
}

/**
 * Get a document by its full URL.
 * Params: url (full Google Docs URL)
 */
function handleGetDocumentByUrl(params) {
  if (!params.url) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'url is required' });
  }

  // Try REST API first for smart chip support
  var docId = extractDocIdFromUrl(params.url);
  if (docId) {
    try {
      return jsonResponse(formatDocumentFromApi(docId));
    } catch (apiErr) {
      // Fall through to DocumentApp
    }
  }

  try {
    var doc = DocumentApp.openByUrl(params.url);
  } catch (err) {
    return handleDocError(err, 'URL: ' + params.url);
  }

  return jsonResponse(formatDocument(doc));
}

// ---------------------------------------------------------------------------
// Write handlers
// ---------------------------------------------------------------------------

/**
 * Create a new document.
 * Params: title (required), content (optional), format (optional: plain|markdown)
 */
function handleCreateDocument(params) {
  if (!params.title) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'title is required' });
  }

  var doc = DocumentApp.create(params.title);
  var body = doc.getBody();

  if (params.content) {
    var fmt = params.format || 'plain';
    if (fmt === 'markdown') {
      // Clear the default empty paragraph before inserting markdown
      body.clear();
      parseMarkdownToDoc(body, params.content);
    } else {
      body.setText(params.content);
    }
  }

  var result = formatDocument(doc);
  result.message = 'Document created';
  return jsonResponse(result);
}

/**
 * Replace a document's content.
 * Params: id (required), content (required), format (optional: plain|markdown)
 */
function handleUpdateDocument(params) {
  if (!params.id) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'id is required' });
  }
  if (!params.content) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'content is required' });
  }

  var doc = openDocById(params.id);
  var body = doc.getBody();
  body.clear();

  var fmt = params.format || 'plain';
  if (fmt === 'markdown') {
    parseMarkdownToDoc(body, params.content);
  } else {
    body.setText(params.content);
  }

  var result = formatDocument(doc);
  result.message = 'Document updated';
  return jsonResponse(result);
}

/**
 * Append content to an existing document.
 * Params: id (required), content (required), format (optional: plain|markdown),
 *         separator (optional: 'true' to insert horizontal rule before content)
 */
function handleAppendContent(params) {
  if (!params.id) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'id is required' });
  }
  if (!params.content) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'content is required' });
  }

  var doc = openDocById(params.id);
  var body = doc.getBody();

  if (params.separator === 'true') {
    body.appendHorizontalRule();
  }

  var fmt = params.format || 'plain';
  if (fmt === 'markdown') {
    parseMarkdownToDoc(body, params.content);
  } else {
    var lines = params.content.split('\n');
    for (var i = 0; i < lines.length; i++) {
      body.appendParagraph(lines[i]);
    }
  }

  var result = formatDocument(doc);
  result.message = 'Content appended';
  return jsonResponse(result);
}

// ---------------------------------------------------------------------------
// Comment handlers (uses Drive API v3 via UrlFetchApp)
// ---------------------------------------------------------------------------

// Force Drive scope so ScriptApp.getOAuthToken() includes it.
// This function is never called — its presence triggers the scope request.
function _forceDriveScope() { DriveApp.getRootFolder(); }
function _forceSheetsScope() { SpreadsheetApp.getActive(); }

/**
 * List comments on a document.
 * Params: id (required), includeResolved (optional: 'true')
 */
function handleGetComments(params) {
  if (!params.id) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'id is required' });
  }

  var token = ScriptApp.getOAuthToken();
  var url = 'https://www.googleapis.com/drive/v3/files/' + params.id +
    '/comments?fields=comments(id,content,author(displayName,emailAddress),createdTime,modifiedTime,resolved,quotedFileContent,replies(id,content,author(displayName,emailAddress),createdTime))&pageSize=100';

  if (params.includeResolved !== 'true') {
    // Drive API doesn't filter by resolved natively, so we filter client-side
  }

  try {
    var response = UrlFetchApp.fetch(url, {
      headers: { 'Authorization': 'Bearer ' + token },
      muteHttpExceptions: true
    });
  } catch (err) {
    return jsonResponse({ ok: false, error: 'api_error', message: 'Failed to fetch comments: ' + err.message });
  }

  var status = response.getResponseCode();
  if (status !== 200) {
    var detail = response.getContentText();
    return jsonResponse({ ok: false, error: 'api_error', message: 'Drive API returned ' + status + ': ' + detail });
  }

  var data = JSON.parse(response.getContentText());
  var comments = (data.comments || []).map(function(c) {
    var comment = {
      id: c.id,
      content: c.content,
      author: c.author ? c.author.displayName : 'Unknown',
      authorEmail: c.author ? c.author.emailAddress : '',
      createdTime: c.createdTime,
      resolved: c.resolved || false,
    };
    if (c.quotedFileContent && c.quotedFileContent.value) {
      comment.quotedText = c.quotedFileContent.value;
    }
    if (c.replies && c.replies.length > 0) {
      comment.replies = c.replies.map(function(r) {
        return {
          id: r.id,
          content: r.content,
          author: r.author ? r.author.displayName : 'Unknown',
          authorEmail: r.author ? r.author.emailAddress : '',
          createdTime: r.createdTime,
        };
      });
    }
    return comment;
  });

  // Filter out resolved unless requested
  if (params.includeResolved !== 'true') {
    comments = comments.filter(function(c) { return !c.resolved; });
  }

  return jsonResponse({
    ok: true,
    documentId: params.id,
    commentCount: comments.length,
    comments: comments,
  });
}

/**
 * Add a comment to a document.
 * Params: id (required), content (required)
 */
function handleAddComment(params) {
  if (!params.id) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'id is required' });
  }
  if (!params.content) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'content is required' });
  }

  var token = ScriptApp.getOAuthToken();
  var url = 'https://www.googleapis.com/drive/v3/files/' + params.id +
    '/comments?fields=id,content,author(displayName,emailAddress),createdTime';

  try {
    var response = UrlFetchApp.fetch(url, {
      method: 'post',
      headers: { 'Authorization': 'Bearer ' + token },
      contentType: 'application/json',
      payload: JSON.stringify({ content: params.content }),
      muteHttpExceptions: true
    });
  } catch (err) {
    return jsonResponse({ ok: false, error: 'api_error', message: 'Failed to add comment: ' + err.message });
  }

  var status = response.getResponseCode();
  if (status !== 200) {
    return jsonResponse({ ok: false, error: 'api_error', message: 'Drive API returned ' + status + ': ' + response.getContentText() });
  }

  var comment = JSON.parse(response.getContentText());
  return jsonResponse({
    ok: true,
    message: 'Comment added',
    comment: {
      id: comment.id,
      content: comment.content,
      author: comment.author ? comment.author.displayName : 'Unknown',
      createdTime: comment.createdTime,
    },
  });
}

/**
 * Resolve a comment.
 * Params: id (document ID, required), commentId (required)
 */
function handleResolveComment(params) {
  if (!params.id) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'id (document ID) is required' });
  }
  if (!params.commentId) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'commentId is required' });
  }

  var token = ScriptApp.getOAuthToken();

  // Resolve by adding a reply with action 'resolve'
  var url = 'https://www.googleapis.com/drive/v3/files/' + params.id +
    '/comments/' + params.commentId + '/replies?fields=id,content,action';

  try {
    var response = UrlFetchApp.fetch(url, {
      method: 'post',
      headers: { 'Authorization': 'Bearer ' + token },
      contentType: 'application/json',
      payload: JSON.stringify({ content: 'Resolved', action: 'resolve' }),
      muteHttpExceptions: true
    });
  } catch (err) {
    return jsonResponse({ ok: false, error: 'api_error', message: 'Failed to resolve comment: ' + err.message });
  }

  var status = response.getResponseCode();
  if (status === 404) {
    return jsonResponse({ ok: false, error: 'not_found', message: 'Comment not found: ' + params.commentId });
  }
  if (status !== 200) {
    return jsonResponse({ ok: false, error: 'api_error', message: 'Drive API returned ' + status + ': ' + response.getContentText() });
  }

  return jsonResponse({
    ok: true,
    message: 'Comment resolved',
    commentId: params.commentId,
  });
}

// ---------------------------------------------------------------------------
// Drive handlers
// ---------------------------------------------------------------------------

/**
 * List files in a Google Drive folder.
 * Params: id (folder ID, required)
 */
function handleListFolder(params) {
  if (!params.id) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'id is required' });
  }

  try {
    var folder = DriveApp.getFolderById(params.id);
  } catch (err) {
    if (err.message.indexOf('not found') !== -1 || err.message.indexOf('is missing') !== -1) {
      return jsonResponse({ ok: false, error: 'not_found', message: 'Folder not found: ' + params.id });
    }
    if (err.message.indexOf('denied') !== -1 || err.message.indexOf('permission') !== -1 || err.message.indexOf('access') !== -1) {
      return jsonResponse({ ok: false, error: 'permission_denied', message: 'No access to folder: ' + params.id });
    }
    throw err;
  }

  var files = [];
  var fileIter = folder.getFiles();
  while (fileIter.hasNext()) {
    var file = fileIter.next();
    files.push({
      id: file.getId(),
      name: file.getName(),
      mimeType: file.getMimeType(),
      url: file.getUrl(),
      lastUpdated: file.getLastUpdated().toISOString(),
    });
  }

  var subfolders = [];
  var folderIter = folder.getFolders();
  while (folderIter.hasNext()) {
    var sub = folderIter.next();
    subfolders.push({
      id: sub.getId(),
      name: sub.getName(),
      url: sub.getUrl(),
    });
  }

  return jsonResponse({
    ok: true,
    id: params.id,
    name: folder.getName(),
    files: files,
    folders: subfolders,
  });
}

// ---------------------------------------------------------------------------
// Spreadsheet handlers
// ---------------------------------------------------------------------------

/**
 * Get spreadsheet metadata and list of sheets.
 * Params: id (spreadsheet ID, required)
 */
function handleGetSpreadsheet(params) {
  if (!params.id) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'id is required' });
  }

  var ss = openSpreadsheetById(params.id);
  var sheets = ss.getSheets().map(function(sheet) {
    return {
      name: sheet.getName(),
      index: sheet.getIndex(),
      rows: sheet.getLastRow(),
      cols: sheet.getLastColumn(),
    };
  });

  return jsonResponse({
    ok: true,
    id: params.id,
    name: ss.getName(),
    url: ss.getUrl(),
    sheets: sheets,
  });
}

/**
 * Read a range from a spreadsheet.
 * Params: id (required), sheet (sheet name, optional - defaults to first sheet),
 *         range (A1 notation, optional - defaults to all data)
 */
function handleReadRange(params) {
  if (!params.id) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'id is required' });
  }

  var ss = openSpreadsheetById(params.id);
  var sheet = params.sheet ? ss.getSheetByName(params.sheet) : ss.getSheets()[0];

  if (!sheet) {
    return jsonResponse({ ok: false, error: 'not_found', message: 'Sheet not found: ' + params.sheet });
  }

  var range;
  if (params.range) {
    try {
      range = sheet.getRange(params.range);
    } catch (err) {
      return jsonResponse({ ok: false, error: 'invalid_range', message: 'Invalid range: ' + params.range });
    }
  } else {
    var lastRow = sheet.getLastRow();
    var lastCol = sheet.getLastColumn();
    if (lastRow === 0 || lastCol === 0) {
      return jsonResponse({
        ok: true,
        id: params.id,
        sheet: sheet.getName(),
        range: 'A1',
        values: [],
      });
    }
    range = sheet.getRange(1, 1, lastRow, lastCol);
  }

  return jsonResponse({
    ok: true,
    id: params.id,
    sheet: sheet.getName(),
    range: range.getA1Notation(),
    values: range.getValues(),
  });
}

/**
 * Write values to a range in a spreadsheet.
 * Params: id (required), sheet (optional), range (A1 notation, required),
 *         values (JSON 2D array, required)
 */
function handleWriteRange(params) {
  if (!params.id) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'id is required' });
  }
  if (!params.range) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'range is required' });
  }
  if (!params.values) {
    return jsonResponse({ ok: false, error: 'missing_param', message: 'values is required (JSON 2D array)' });
  }

  var ss = openSpreadsheetById(params.id);
  var sheet = params.sheet ? ss.getSheetByName(params.sheet) : ss.getSheets()[0];

  if (!sheet) {
    return jsonResponse({ ok: false, error: 'not_found', message: 'Sheet not found: ' + params.sheet });
  }

  var values;
  try {
    values = JSON.parse(params.values);
  } catch (err) {
    return jsonResponse({ ok: false, error: 'invalid_param', message: 'values must be a valid JSON 2D array' });
  }

  if (!Array.isArray(values) || !Array.isArray(values[0])) {
    return jsonResponse({ ok: false, error: 'invalid_param', message: 'values must be a 2D array' });
  }

  try {
    var range = sheet.getRange(params.range);
    // Resize range to match values dimensions
    range = sheet.getRange(range.getRow(), range.getColumn(), values.length, values[0].length);
    range.setValues(values);
  } catch (err) {
    return jsonResponse({ ok: false, error: 'write_failed', message: 'Failed to write: ' + err.message });
  }

  return jsonResponse({
    ok: true,
    id: params.id,
    sheet: sheet.getName(),
    range: range.getA1Notation(),
    message: 'Range updated',
  });
}

/**
 * Open a spreadsheet by ID with consistent error handling.
 */
function openSpreadsheetById(id) {
  try {
    return SpreadsheetApp.openById(id);
  } catch (err) {
    if (err.message.indexOf('not found') !== -1 || err.message.indexOf('is missing') !== -1) {
      throw { isAppError: true, response: { ok: false, error: 'not_found', message: 'Spreadsheet not found: ' + id } };
    }
    if (err.message.indexOf('denied') !== -1 || err.message.indexOf('permission') !== -1 || err.message.indexOf('access') !== -1) {
      throw { isAppError: true, response: { ok: false, error: 'permission_denied', message: 'No access to spreadsheet: ' + id } };
    }
    throw err;
  }
}

// ---------------------------------------------------------------------------
// Document helpers
// ---------------------------------------------------------------------------

/**
 * Open a document by ID with consistent error handling.
 */
function openDocById(id) {
  try {
    return DocumentApp.openById(id);
  } catch (err) {
    // handleDocError throws a jsonResponse, but we need to return it.
    // Re-throw with a marker so the caller can catch it.
    if (err.message.indexOf('not found') !== -1 || err.message.indexOf('is missing') !== -1) {
      throw { isAppError: true, response: { ok: false, error: 'not_found', message: 'Document not found: ' + id } };
    }
    if (err.message.indexOf('denied') !== -1 || err.message.indexOf('permission') !== -1 || err.message.indexOf('access') !== -1) {
      throw { isAppError: true, response: { ok: false, error: 'permission_denied', message: 'No access to document: ' + id } };
    }
    throw err;
  }
}

/**
 * Handle common document open errors — returns a jsonResponse.
 */
function handleDocError(err, identifier) {
  if (err.message.indexOf('not found') !== -1 || err.message.indexOf('is missing') !== -1) {
    return jsonResponse({ ok: false, error: 'not_found', message: 'Document not found: ' + identifier });
  }
  if (err.message.indexOf('denied') !== -1 || err.message.indexOf('permission') !== -1 || err.message.indexOf('access') !== -1) {
    return jsonResponse({ ok: false, error: 'permission_denied', message: 'No access to document: ' + identifier });
  }
  throw err;
}

/**
 * Extract document content as a structured tree.
 * Returns an array of block elements, each with typed inline runs.
 */
function formatDocument(doc) {
  var body = doc.getBody();
  var id = doc.getId();

  var elements = [];
  var numChildren = body.getNumChildren();

  for (var i = 0; i < numChildren; i++) {
    var child = body.getChild(i);
    var type = child.getType();

    if (type === DocumentApp.ElementType.PARAGRAPH) {
      var para = child.asParagraph();
      var heading = para.getHeading();
      var element = { type: 'paragraph', runs: extractRuns(para) };

      if (heading !== DocumentApp.ParagraphHeading.NORMAL) {
        element.type = 'heading';
        element.level = headingLevel(heading);
      }

      elements.push(element);

    } else if (type === DocumentApp.ElementType.LIST_ITEM) {
      var item = child.asListItem();
      var glyph = item.getGlyphType();
      var ordered = (glyph === DocumentApp.GlyphType.NUMBER ||
                     glyph === DocumentApp.GlyphType.LATIN_UPPER ||
                     glyph === DocumentApp.GlyphType.LATIN_LOWER ||
                     glyph === DocumentApp.GlyphType.ROMAN_UPPER ||
                     glyph === DocumentApp.GlyphType.ROMAN_LOWER);

      elements.push({
        type: 'list_item',
        ordered: ordered,
        nesting: item.getNestingLevel(),
        runs: extractRuns(item),
      });

    } else if (type === DocumentApp.ElementType.HORIZONTAL_RULE) {
      elements.push({ type: 'horizontal_rule' });

    } else if (type === DocumentApp.ElementType.TABLE) {
      elements.push(extractTable(child.asTable()));
    }
  }

  return {
    ok: true,
    id: id,
    title: doc.getName(),
    url: 'https://docs.google.com/document/d/' + id + '/edit',
    elements: elements,
  };
}

/**
 * Extract inline runs from a paragraph or list item.
 * Each run has text and optional formatting flags.
 */
function extractRuns(element) {
  var text = element.editAsText();
  var content = text.getText();
  if (!content) return [];

  var runs = [];
  var i = 0;
  var len = content.length;

  while (i < len) {
    var bold = text.isBold(i) || false;
    var italic = text.isItalic(i) || false;
    var linkUrl = text.getLinkUrl(i);
    var fontFamily = text.getFontFamily(i);

    var j = i + 1;
    while (j < len) {
      if ((text.isBold(j) || false) !== bold ||
          (text.isItalic(j) || false) !== italic ||
          text.getLinkUrl(j) !== linkUrl ||
          text.getFontFamily(j) !== fontFamily) break;
      j++;
    }

    var run = { text: content.substring(i, j) };
    if (bold) run.bold = true;
    if (italic) run.italic = true;
    if (linkUrl) run.url = linkUrl;
    if (fontFamily && fontFamily.toLowerCase().indexOf('courier') !== -1) run.code = true;

    runs.push(run);
    i = j;
  }

  return runs;
}

/**
 * Extract a table as structured rows and cells.
 */
function extractTable(table) {
  var rows = [];
  for (var r = 0; r < table.getNumRows(); r++) {
    var row = table.getRow(r);
    var cells = [];
    for (var c = 0; c < row.getNumCells(); c++) {
      cells.push(row.getCell(c).getText());
    }
    rows.push(cells);
  }
  return { type: 'table', rows: rows };
}

// ---------------------------------------------------------------------------
// REST API-based extraction (Docs Advanced Service) - preserves smart chips
// ---------------------------------------------------------------------------

/**
 * Extract doc ID from a Google Docs URL.
 */
function extractDocIdFromUrl(url) {
  var match = url.match(/\/document\/d\/([a-zA-Z0-9_-]+)/);
  return match ? match[1] : null;
}

/**
 * Extract document content via the Docs REST API (Advanced Service).
 * Unlike DocumentApp, this preserves smart chip content (person mentions,
 * dates, rich links). Requires the "Google Docs API" Advanced Service.
 */
function formatDocumentFromApi(docId) {
  var doc = Docs.Documents.get(docId);
  var body = doc.body;
  var elements = [];

  if (!body || !body.content) {
    return {
      ok: true,
      id: docId,
      title: doc.title,
      url: 'https://docs.google.com/document/d/' + docId + '/edit',
      elements: [],
    };
  }

  for (var i = 0; i < body.content.length; i++) {
    var structural = body.content[i];

    if (structural.paragraph) {
      var para = structural.paragraph;
      var runs = extractApiRuns(para.elements || []);
      if (runs.length === 0) continue;

      var element = { type: 'paragraph', runs: runs };

      // Heading detection
      if (para.paragraphStyle && para.paragraphStyle.namedStyleType) {
        var style = para.paragraphStyle.namedStyleType;
        if (style === 'TITLE') {
          element.type = 'heading';
          element.level = 0;
        } else if (style.indexOf('HEADING_') === 0) {
          element.type = 'heading';
          element.level = parseInt(style.replace('HEADING_', ''), 10);
        }
      }

      // List item detection
      if (para.bullet) {
        element.type = 'list_item';
        element.nesting = para.bullet.nestingLevel || 0;
        element.ordered = false;
        if (para.bullet.listId && doc.lists && doc.lists[para.bullet.listId]) {
          var listProps = doc.lists[para.bullet.listId].listProperties;
          if (listProps && listProps.nestingLevels) {
            var nest = listProps.nestingLevels[element.nesting];
            if (nest && nest.glyphType &&
                (nest.glyphType === 'DECIMAL' ||
                 nest.glyphType === 'ALPHA' ||
                 nest.glyphType === 'ROMAN' ||
                 nest.glyphType === 'UPPER_ALPHA' ||
                 nest.glyphType === 'UPPER_ROMAN')) {
              element.ordered = true;
            }
          }
        }
      }

      elements.push(element);

    } else if (structural.table) {
      elements.push(extractApiTable(structural.table));
    }
    // Skip sectionBreak, tableOfContents
  }

  return {
    ok: true,
    id: docId,
    title: doc.title,
    url: 'https://docs.google.com/document/d/' + docId + '/edit',
    elements: elements,
  };
}

/**
 * Extract inline runs from REST API paragraph elements.
 * Handles textRun, person (smart chip), richLink (smart chip),
 * and horizontalRule.
 */
function extractApiRuns(elements) {
  var runs = [];

  for (var i = 0; i < elements.length; i++) {
    var el = elements[i];

    if (el.textRun) {
      var text = el.textRun.content || '';
      // Strip trailing newline (paragraphs always end with \n)
      text = text.replace(/\n$/, '');
      if (!text) continue;

      var run = { text: text };
      var ts = el.textRun.textStyle || {};
      if (ts.bold) run.bold = true;
      if (ts.italic) run.italic = true;
      if (ts.link && ts.link.url) run.url = ts.link.url;
      if (ts.weightedFontFamily &&
          ts.weightedFontFamily.fontFamily &&
          ts.weightedFontFamily.fontFamily.toLowerCase().indexOf('courier') !== -1) {
        run.code = true;
      }
      runs.push(run);

    } else if (el.person) {
      var props = el.person.personProperties || {};
      var name = props.name || props.email || 'Unknown';
      runs.push({ text: name });

    } else if (el.dateElement) {
      var dateProps = el.dateElement.dateElementProperties || {};
      var dateText = dateProps.displayText || dateProps.timestamp || 'Unknown date';
      runs.push({ text: dateText });

    } else if (el.richLink) {
      var rlProps = el.richLink.richLinkProperties || {};
      var title = rlProps.title || rlProps.uri || 'Link';
      var uri = rlProps.uri || '';
      var run = { text: title };
      if (uri) run.url = uri;
      runs.push(run);

    } else if (el.horizontalRule) {
      // Inline HR within a paragraph - rare but possible
      runs.push({ text: '---' });

    } else if (el.inlineObjectElement) {
      runs.push({ text: '[image]' });
    }
    // Skip pageBreak, columnBreak, footnoteReference, equation, autoText
  }

  return runs;
}

/**
 * Extract a table from the REST API response.
 * Returns same format as extractTable(): {type:'table', rows:[['cell',...],...]}
 */
function extractApiTable(table) {
  var rows = [];
  if (!table.tableRows) return { type: 'table', rows: rows };

  for (var r = 0; r < table.tableRows.length; r++) {
    var row = [];
    var cells = table.tableRows[r].tableCells || [];
    for (var c = 0; c < cells.length; c++) {
      var cellText = '';
      var content = cells[c].content || [];
      for (var p = 0; p < content.length; p++) {
        if (content[p].paragraph) {
          var cellRuns = extractApiRuns(content[p].paragraph.elements || []);
          for (var ri = 0; ri < cellRuns.length; ri++) {
            cellText += cellRuns[ri].text;
          }
          if (p < content.length - 1) cellText += '\n';
        }
      }
      row.push(cellText);
    }
    rows.push(row);
  }
  return { type: 'table', rows: rows };
}

// ---------------------------------------------------------------------------
// DocumentApp-based extraction (fallback when Advanced Service unavailable)
// ---------------------------------------------------------------------------

/**
 * Map Apps Script heading enum to numeric level.
 */
function headingLevel(heading) {
  switch (heading) {
    case DocumentApp.ParagraphHeading.TITLE: return 0;
    case DocumentApp.ParagraphHeading.HEADING1: return 1;
    case DocumentApp.ParagraphHeading.HEADING2: return 2;
    case DocumentApp.ParagraphHeading.HEADING3: return 3;
    case DocumentApp.ParagraphHeading.HEADING4: return 4;
    case DocumentApp.ParagraphHeading.HEADING5: return 5;
    case DocumentApp.ParagraphHeading.HEADING6: return 6;
    default: return -1;
  }
}

/**
 * Map numeric level to Apps Script heading enum.
 */
function headingEnum(level) {
  switch (level) {
    case 1: return DocumentApp.ParagraphHeading.HEADING1;
    case 2: return DocumentApp.ParagraphHeading.HEADING2;
    case 3: return DocumentApp.ParagraphHeading.HEADING3;
    case 4: return DocumentApp.ParagraphHeading.HEADING4;
    case 5: return DocumentApp.ParagraphHeading.HEADING5;
    case 6: return DocumentApp.ParagraphHeading.HEADING6;
    default: return DocumentApp.ParagraphHeading.NORMAL;
  }
}

// ---------------------------------------------------------------------------
// Markdown parser
// ---------------------------------------------------------------------------

/**
 * Parse markdown text and append formatted content to a Google Doc body.
 * Supports: headings, bold, italic, inline code, links, bullet/numbered lists,
 * horizontal rules, blockquotes, and fenced code blocks.
 */
function parseMarkdownToDoc(body, markdownText) {
  var blocks = splitIntoBlocks(markdownText);

  for (var i = 0; i < blocks.length; i++) {
    var block = blocks[i];

    switch (block.type) {
      case 'heading':
        var p = body.appendParagraph('');
        p.setHeading(headingEnum(block.level));
        setTextWithInlineFormatting(p, block.content);
        break;

      case 'hr':
        body.appendHorizontalRule();
        break;

      case 'bullet':
        var li = body.appendListItem('');
        li.setGlyphType(DocumentApp.GlyphType.BULLET);
        setTextWithInlineFormatting(li, block.content);
        break;

      case 'number':
        var li = body.appendListItem('');
        li.setGlyphType(DocumentApp.GlyphType.NUMBER);
        setTextWithInlineFormatting(li, block.content);
        break;

      case 'quote':
        var p = body.appendParagraph('');
        p.setIndentStart(36); // ~0.5 inch indent
        p.setAttributes({});
        var attrs = {};
        attrs[DocumentApp.Attribute.ITALIC] = true;
        setTextWithInlineFormatting(p, block.content);
        p.editAsText().setItalic(true);
        break;

      case 'code':
        var codeLines = block.content.split('\n');
        for (var j = 0; j < codeLines.length; j++) {
          var cp = body.appendParagraph(codeLines[j]);
          cp.editAsText().setFontFamily('Courier New');
          cp.editAsText().setBackgroundColor('#f0f0f0');
          cp.editAsText().setFontSize(10);
        }
        break;

      case 'paragraph':
        var p = body.appendParagraph('');
        setTextWithInlineFormatting(p, block.content);
        break;
    }
  }
}

/**
 * Split markdown text into block-level elements.
 * Returns array of {type, content, level?} objects.
 */
function splitIntoBlocks(text) {
  var lines = text.split('\n');
  var blocks = [];
  var i = 0;

  while (i < lines.length) {
    var line = lines[i];

    // Fenced code block
    if (line.match(/^```/)) {
      var codeLines = [];
      i++;
      while (i < lines.length && !lines[i].match(/^```/)) {
        codeLines.push(lines[i]);
        i++;
      }
      blocks.push({ type: 'code', content: codeLines.join('\n') });
      i++; // skip closing ```
      continue;
    }

    // Heading
    var headingMatch = line.match(/^(#{1,6})\s+(.*)/);
    if (headingMatch) {
      blocks.push({ type: 'heading', level: headingMatch[1].length, content: headingMatch[2] });
      i++;
      continue;
    }

    // Horizontal rule
    if (line.match(/^(-{3,}|\*{3,}|_{3,})$/)) {
      blocks.push({ type: 'hr' });
      i++;
      continue;
    }

    // Unordered list item
    if (line.match(/^[\*\-]\s+/)) {
      blocks.push({ type: 'bullet', content: line.replace(/^[\*\-]\s+/, '') });
      i++;
      continue;
    }

    // Ordered list item
    var olMatch = line.match(/^\d+\.\s+(.*)/);
    if (olMatch) {
      blocks.push({ type: 'number', content: olMatch[1] });
      i++;
      continue;
    }

    // Blockquote
    if (line.match(/^>\s*/)) {
      blocks.push({ type: 'quote', content: line.replace(/^>\s*/, '') });
      i++;
      continue;
    }

    // Empty line — skip
    if (line.trim() === '') {
      i++;
      continue;
    }

    // Regular paragraph
    blocks.push({ type: 'paragraph', content: line });
    i++;
  }

  return blocks;
}

// ---------------------------------------------------------------------------
// Inline formatting
// ---------------------------------------------------------------------------

/**
 * Set text on a paragraph/list-item and apply inline markdown formatting.
 * Processes: bold-italic (***), bold (**), italic (* or _), inline code (`),
 * and links [text](url).
 *
 * Strategy: parse the markdown into segments, build plain text, then apply
 * formatting to the correct character ranges.
 */
function setTextWithInlineFormatting(element, markdown) {
  var segments = parseInlineMarkdown(markdown);

  // Build plain text from segments
  var plainText = '';
  for (var i = 0; i < segments.length; i++) {
    plainText += segments[i].text;
  }

  if (plainText === '') {
    return;
  }

  element.setText(plainText);
  var textEl = element.editAsText();

  // Apply formatting to each segment
  var offset = 0;
  for (var i = 0; i < segments.length; i++) {
    var seg = segments[i];
    var start = offset;
    var end = offset + seg.text.length - 1;

    if (seg.text.length > 0) {
      if (seg.bold) textEl.setBold(start, end, true);
      if (seg.italic) textEl.setItalic(start, end, true);
      if (seg.code) {
        textEl.setFontFamily(start, end, 'Courier New');
        textEl.setBackgroundColor(start, end, '#f0f0f0');
      }
      if (seg.url) {
        textEl.setLinkUrl(start, end, seg.url);
      }
    }

    offset += seg.text.length;
  }
}

/**
 * Parse a markdown string into an array of segments with formatting flags.
 * Each segment: {text, bold, italic, code, url}
 *
 * Processes patterns in priority order:
 *   1. Inline code (`) — no nested formatting inside code
 *   2. Links [text](url)
 *   3. Bold-italic (*** or ___)
 *   4. Bold (** or __)
 *   5. Italic (* or _)
 */
function parseInlineMarkdown(text) {
  // Tokenize into runs that alternate between special and plain
  var tokens = [];
  var i = 0;
  var len = text.length;

  while (i < len) {
    // Inline code
    if (text[i] === '`') {
      var end = text.indexOf('`', i + 1);
      if (end !== -1) {
        tokens.push({ text: text.substring(i + 1, end), code: true });
        i = end + 1;
        continue;
      }
    }

    // Link [text](url)
    if (text[i] === '[') {
      var closeBracket = text.indexOf(']', i + 1);
      if (closeBracket !== -1 && text[closeBracket + 1] === '(') {
        var closeParen = text.indexOf(')', closeBracket + 2);
        if (closeParen !== -1) {
          var linkText = text.substring(i + 1, closeBracket);
          var linkUrl = text.substring(closeBracket + 2, closeParen);
          tokens.push({ text: linkText, url: linkUrl });
          i = closeParen + 1;
          continue;
        }
      }
    }

    // Bold-italic (***text***)
    if (text.substring(i, i + 3) === '***') {
      var end = text.indexOf('***', i + 3);
      if (end !== -1) {
        tokens.push({ text: text.substring(i + 3, end), bold: true, italic: true });
        i = end + 3;
        continue;
      }
    }

    // Bold (**text**)
    if (text.substring(i, i + 2) === '**') {
      var end = text.indexOf('**', i + 2);
      if (end !== -1) {
        tokens.push({ text: text.substring(i + 2, end), bold: true });
        i = end + 2;
        continue;
      }
    }

    // Italic (*text* but not **) — single asterisk
    if (text[i] === '*' && (i + 1 >= len || text[i + 1] !== '*')) {
      var end = text.indexOf('*', i + 1);
      if (end !== -1 && (end + 1 >= len || text[end + 1] !== '*')) {
        tokens.push({ text: text.substring(i + 1, end), italic: true });
        i = end + 1;
        continue;
      }
    }

    // Italic with underscore (_text_)
    if (text[i] === '_' && (i + 1 >= len || text[i + 1] !== '_')) {
      var end = text.indexOf('_', i + 1);
      if (end !== -1) {
        tokens.push({ text: text.substring(i + 1, end), italic: true });
        i = end + 1;
        continue;
      }
    }

    // Plain character — accumulate into a plain segment
    var plainStart = i;
    while (i < len && text[i] !== '`' && text[i] !== '[' && text[i] !== '*' && text[i] !== '_') {
      i++;
    }
    if (i > plainStart) {
      tokens.push({ text: text.substring(plainStart, i) });
    } else {
      // Current character didn't match any pattern — consume it as plain
      tokens.push({ text: text[i] });
      i++;
    }
  }

  return tokens;
}

// ---------------------------------------------------------------------------
// Response helper
// ---------------------------------------------------------------------------

/**
 * Helper to create a JSON response.
 */
function jsonResponse(data) {
  return ContentService
    .createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
}
