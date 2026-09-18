#!/bin/bash
HOOK='https://discord.com/api/webhooks/...'
DIR=/srv/ibmi

for f in "$DIR"/fullsave-ok.txt "$DIR"/fullsave-failed.txt; do
    [ -s "$f" ] || continue
    case "$f" in
        *-ok.txt) MSG=":white_check_mark: **QS-HQ-P520 FULLSAVE**: Completed $(date '+%F %H:%M')" ;;
        *) MSG=":x: **QS-HQ-P520 FULLSAVE**: Failed $(date '+%F %H:%M') - Check QSYSOPR" ;;
    esac
    sed -n '/=== FULLSAVE START ===/,$p' "$f" | sed 's/[[:space:]]*$//' > "$f.trim"
        [ -s "$f.trim" ] || cp "$f" "$f.trim"          # No marker? Send the whole thing
    curl -sS -F "content=$MSG" -F "files[0]=@$f.trim;filename=fullsave.txt" "$HOOK" \
        && mv "$f" "$DIR/sent/$(date +%Y%m%d-%H%M)-$(basename "$f")"
        rm -f "$f.trim"
done