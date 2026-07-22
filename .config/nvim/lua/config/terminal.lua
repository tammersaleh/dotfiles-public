-- Terminal configuration

local M = {}

-- Let the outer terminal (iTerm2) tab title track Claude's title. Claude Code,
-- and its /rename command, emit an OSC title sequence; we mirror it into the
-- global titlestring so the tab follows Claude no matter which buffer is
-- focused. titlestring is global (one per Neovim instance), so pinning it to a
-- literal string makes the title focus-independent.
--
-- Only Claude terminals drive the title. A plain ':terminal' runs a shell whose
-- prompt emits its own OSC title (the cwd basename); those must not clobber
-- Claude's title.
vim.o.title = true

-- Escape '%' so titlestring does not interpret it as a statusline item.
local function title_to_string(title)
  return (title:gsub('%%', '%%%%'))
end

-- A terminal buffer name is "term://{cwd}//{pid}:{command}". Match "claude" in
-- the command only, never the cwd (the cwd is often ~/.claude).
function M.is_claude_terminal(bufname)
  local command = bufname:match('//%d+:(.*)$')
  return command ~= nil and command:find('claude', 1, true) ~= nil
end

-- Function to save the last mode (used by splits.lua too, but defined locally here for terminal windows)
local function save_last_mode()
  vim.b._last_mode = vim.api.nvim_get_mode().mode
end

-- Open terminal in current buffer
vim.keymap.set('n', '<Leader>t', function()
  if vim.api.nvim_get_option_value('modified', {buf = 0}) then
    print("Buffer modified.  Save before replacing with a terminal")
    return nil
  end
  if vim.api.nvim_buf_get_name(0) ~= "" then
    vim.cmd('lcd %:h')
  end

  local old_buf = vim.api.nvim_get_current_buf()
  vim.cmd('terminal')
  local term_buf = vim.api.nvim_get_current_buf()

  if old_buf ~= term_buf then
    vim.api.nvim_buf_delete(old_buf, {})
  end
end, {desc = "Open terminal in current buffer"})

-- Terminal autocommands
local vim_term = vim.api.nvim_create_augroup('vim_term', { clear = true })

vim.api.nvim_create_autocmd('TermOpen', {
  callback = function()
    vim.opt_local.relativenumber = false
    vim.opt_local.number = false
    vim.cmd "startinsert!"
    save_last_mode()
  end,
  group = vim_term
})

-- Pin the tab title to the OSC title a Claude terminal sets (OSC 0 = icon+title,
-- 1 = icon, 2 = title). Parsing straight from the sequence avoids depending on
-- when Neovim updates b:term_title. Non-Claude terminals are ignored.
vim.api.nvim_create_autocmd('TermRequest', {
  callback = function(ev)
    if not M.is_claude_terminal(vim.api.nvim_buf_get_name(ev.buf)) then
      return
    end
    local seq = ev.data and ev.data.sequence or ''
    local title = seq:match('^\27%][012];(.*)$')
    if title and title ~= '' then
      vim.o.titlestring = title_to_string(title)
    end
  end,
  group = vim_term
})

-- True if a Claude terminal other than exclude_buf is still open.
local function any_claude_terminal_left(exclude_buf)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= exclude_buf
      and vim.api.nvim_buf_is_loaded(buf)
      and vim.bo[buf].buftype == 'terminal'
      and M.is_claude_terminal(vim.api.nvim_buf_get_name(buf)) then
      return true
    end
  end
  return false
end

-- Close the terminal as soon as its shell exits, regardless of exit code.
-- Neovim otherwise leaves the buffer showing "[Process exited N]" until a key
-- is pressed. If the terminal is the whole editor, quit; otherwise just close
-- it (dropping a split, returning to the alternate file).
vim.api.nvim_create_autocmd('TermClose', {
  callback = function(args)
    local buf = args.buf
    if not any_claude_terminal_left(buf) then
      vim.o.titlestring = ''
    end
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      if #vim.api.nvim_list_tabpages() == 1 and #vim.api.nvim_list_wins() == 1 then
        vim.cmd.quitall()
      else
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end)
  end,
  group = vim_term
})

vim.api.nvim_create_autocmd('WinEnter', {
  pattern = "term://*",
  callback = function()
    if vim.b._last_mode == 't' then
      vim.cmd.startinsert()
    end
  end,
  group = vim_term
})

-- Exit insert mode via ctrl-u
vim.keymap.set('t', "<c-u>", "<c-\\><c-n>", {desc = "Exit terminal insert mode"})

return M
