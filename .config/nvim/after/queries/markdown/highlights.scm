; extends

; Dim a checked item and everything nested under it. Priority 200 beats the
; inline highlights (100) so links, bold, and code dim too.
((list_item
  (task_list_marker_checked)) @markup.list.checked.item
  (#set! priority 200))
