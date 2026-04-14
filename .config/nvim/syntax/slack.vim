" Vim syntax file
" Language: Slack mrkdwn
" Based on: https://gist.github.com/sukima/6040ca57c6929aea33fff59ceaca433e

if exists("b:current_syntax")
  finish
endif

syn case ignore

syn cluster slackEntities contains=slackUrl,slackLink,slackInlineCode,slackEmoji,slackChannel,slackMention
syn cluster slackInline contains=@slackEntities,slackBold,slackItalic,slackStrike

syn match slackBold "\*[^*]\+\*" oneline contains=@slackEntities
syn match slackItalic "_[^_]\+_" oneline contains=@slackEntities
syn match slackStrike "\~[^~]\+\~" oneline contains=@slackEntities
syn match slackEmoji ":[[:alnum:]_+-]\+:" oneline
syn match slackInlineCode "`[^`]\+`" oneline
syn match slackLink "<[^>]*|[^>]*>" oneline contains=slackUrl
syn match slackUrl "\<https\?://[[:alnum:]\-_.+%?=&#/:]\+" oneline
syn match slackChannel "<#[[:alnum:]_-]\+>" oneline
syn match slackMention "<@[[:alnum:]_.]\+>" oneline
syn match slackQuote "^>.*$" oneline contains=@slackInline
syn region slackCodeBlock start="^```" end="^```" contains=slackCodeDelimiter
syn match slackCodeDelimiter "```" contained

hi def slackBold term=bold cterm=bold gui=bold
hi def slackItalic term=italic cterm=italic gui=italic
hi def slackStrike term=strikethrough cterm=strikethrough gui=strikethrough
hi def link slackEmoji Type
hi def link slackChannel Type
hi def link slackMention Type
hi def link slackInlineCode String
hi def link slackLink Underlined
hi def link slackUrl Underlined
hi def link slackQuote Comment
hi def link slackCodeBlock String
hi def link slackCodeDelimiter Delimiter

let b:current_syntax = "slack"
