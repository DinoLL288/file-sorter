#!/bin/zsh
set -u

DESKTOP_DIR="$HOME/Desktop"
SCREENSHOT_DIR="$HOME/Desktop/Screenshots"
LOG_FILE="$HOME/Library/Logs/sort-screenshots-by-date.log"

mkdir -p "$SCREENSHOT_DIR"

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
    if [[ -n "$ext" ]]; then
      candidate="$dir/$base $i.$ext"
    else
      candidate="$dir/$base $i"
    fi
    (( i++ ))
  done

  printf '%s\n' "$candidate"
}

sort_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  [[ "${file:t}" == .* ]] && return 0
  case "${file:t:l}" in
    screenshot\ *|screen\ shot\ *) ;;
    *) return 0 ;;
  esac
  case "${file:e:l}" in
    png|jpg|jpeg|heic|tiff|gif|pdf|mov) ;;
    *) return 0 ;;
  esac

  local day year destination target
  day="$(date_for_file "$file")"
  [[ -n "$day" ]] || {
    log "Skipped, no date: $file"
    return 0
  }

  year="${day%%-*}"
  destination="$SCREENSHOT_DIR/$year/$day"
  mkdir -p "$destination"

  target="$(unique_target "$destination/${file:t}")"
  if [[ "$file" != "$target" ]]; then
    mv "$file" "$target"
    log "Moved: $file -> $target"
  fi
}

merge_date_folder() {
  local folder="$1"
  local name="${folder:t}"
  [[ -d "$folder" ]] || return 0
  [[ "$name" == <-><-><-><->-<-><->-<-><-> ]] || return 0

  local year="${name%%-*}"
  local destination="$SCREENSHOT_DIR/$year/$name"
  [[ "$folder" == "$destination" ]] && return 0

  mkdir -p "$destination"

  find "$folder" -mindepth 1 -maxdepth 1 -print0 | while IFS= read -r -d '' item; do
    local target
    target="$(unique_target "$destination/${item:t}")"
    mv "$item" "$target"
    log "Moved: $item -> $target"
  done

  rmdir "$folder" 2>/dev/null || true
}

find "$SCREENSHOT_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | while IFS= read -r -d '' folder; do
  merge_date_folder "$folder"
done

find "$SCREENSHOT_DIR" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' file; do
  sort_file "$file"
done

find "$SCREENSHOT_DIR" -mindepth 2 -maxdepth 2 -type f -print0 | while IFS= read -r -d '' file; do
  sort_file "$file"
done

find "$DESKTOP_DIR" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' file; do
  sort_file "$file"
done
