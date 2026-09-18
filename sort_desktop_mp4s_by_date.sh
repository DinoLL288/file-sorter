#!/bin/zsh
set -u

WATCH_DIR="$HOME/Desktop"
VIDEO_DIR="$HOME/Desktop/MP4s"
LOG_FILE="$HOME/Library/Logs/sort-desktop-mp4s-by-date.log"

mkdir -p "$VIDEO_DIR"

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE"
}

date_for_file() {
  local file="$1"
  local raw

  raw="$(mdls -raw -name kMDItemContentCreationDate "$file" 2>/dev/null || true)"
  if [[ -n "$raw" && "$raw" != "(null)" ]]; then
    date -j -f "%Y-%m-%d %H:%M:%S %z" "$raw +0000" "+%Y-%m-%d" 2>/dev/null && return 0
  fi

  stat -f "%Sm" -t "%Y-%m-%d" "$file" 2>/dev/null
}

unique_target() {
  local target="$1"
  local dir="${target:h}"
  local base="${target:t:r}"
  local ext="${target:e}"
  local candidate="$target"
  local i=1

  while [[ -e "$candidate" ]]; do
    candidate="$dir/$base $i.$ext"
    (( i++ ))
  done

  printf '%s\n' "$candidate"
}

sort_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  [[ "${file:t}" == .* ]] && return 0
  case "${file:e:l}" in
    mp4|mov) ;;
    *) return 0 ;;
  esac

  local day year destination target
  day="$(date_for_file "$file")"
  [[ -n "$day" ]] || {
    log "Skipped, no date: $file"
    return 0
  }

  year="${day%%-*}"
  destination="$VIDEO_DIR/$year/$day"
  mkdir -p "$destination"

  target="$(unique_target "$destination/${file:t}")"
  if [[ "$file" != "$target" ]]; then
    mv "$file" "$target"
    log "Moved: $file -> $target"
  fi
}

find "$WATCH_DIR" -maxdepth 1 -type f \( -iname '*.mp4' -o -iname '*.mov' \) -print0 | while IFS= read -r -d '' file; do
  sort_file "$file"
done

find "$VIDEO_DIR" -maxdepth 1 -type f \( -iname '*.mp4' -o -iname '*.mov' \) -print0 | while IFS= read -r -d '' file; do
  sort_file "$file"
done
