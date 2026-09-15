# Ghostty

Port of the iTerm2 "Default" profile (`~/dotfiles/public/.iterm2`). Ghostty
1.3.1. Validate with `ghostty +validate-config`; inspect the effective config
with `ghostty +show-config`.

## Layout

`config` holds everything except colors. `themes/iterm-light` and
`themes/iterm-dark` hold the iTerm2 light and dark color sets; `theme =
light:...,dark:...` switches with system appearance.

## Differences from iTerm2

Scrollback is capped at Ghostty's 10MB default per surface. iTerm2 was
unlimited, a likely source of its memory use. Ghostty cannot do unlimited.
Claude runs on nvim's alternate screen, so nvim's terminal buffer holds that
history, not Ghostty.

`TERM` is `xterm-ghostty`, not `xterm-256color`. Remote hosts lack that
terminfo. `ssh-env` in `shell-integration-features` rewrites `TERM` to
`xterm-256color` for outgoing ssh. Set `ssh-terminfo` instead to install the
entry on remote hosts.

Shift+Enter and Ctrl+Shift+Space have no keybinds. iTerm2 needed them
(Shift+Enter sent LF, Ctrl+Shift+Space sent `CSI 27;6;32~`) because it did
not disambiguate those chords by default. Ghostty, nvim's `:terminal` (kitty
protocol, disambiguate mode, since 0.11), and Claude Code all speak the kitty
keyboard protocol, so both chords arrive intact. Unverified in a live session;
if Shift+Enter submits in Claude, add `keybind = shift+enter=text:\n`. No
consumer for the Ctrl+Shift+Space sequence exists in the dotfiles.

Option is not Meta, as in iTerm2. Claude Code's Option+Enter and Option+P
shortcuts need `macos-option-as-alt = true`.

Bell: iTerm2 was silent with a visual flash. Ghostty flashes a border around
the surface. Dock bounce and title bell are off.

Notifications: Claude Code sends OSC 9 desktop notifications, which Ghostty
handles. `lua/config/terminal.lua` in the nvim config forwards OSC 9 from the
child to the host terminal; that still works. It also forwards iTerm2's OSC
1337 RequestAttention, which Ghostty ignores. `preferredNotifChannel:
"iterm2"` in `~/.claude/settings.json` can be removed; Claude Code detects
Ghostty on its own.

Tab bar: no HTML tab titles, no tab bar font size, no "stretch tabs". Native
macOS tabs with a transparent titlebar (Ghostty default). `macos-titlebar-style
= tabs` moves tabs into the titlebar but does not recolor on appearance change.

Unfocused-window dimming (iTerm2 "Dim background windows") has no equivalent.
Split dimming is `unfocused-split-opacity`.

Updates: the Homebrew cask is `auto_updates`, so `brew upgrade` skips it.
`auto-update = check` makes Ghostty prompt when a release is out.

Dropped as inapplicable: blur (iTerm2 had blur on but zero transparency),
Non-ASCII font (disabled in iTerm2), status bar, iTerm2 AI settings, "disable
Metal when unplugged", "Disable Window Resizing" (Ghostty has no
escape-sequence window resizing).

The iTerm2 shell integration script in `~/.zsh/d/iterm2_shell_integration.zsh`
is harmless under Ghostty but redundant; Ghostty injects its own zsh
integration.
