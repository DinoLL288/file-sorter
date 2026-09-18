# File Sorter

Two lightweight zsh scripts that keep your macOS Desktop tidy by automatically filing screenshots and screen recordings into date-organized folders.

They run via [launchd](https://www.launchd.info/) LaunchAgents that watch the Desktop and fire every 10 seconds.

## Scripts

### `sort_screenshots_by_date.sh`
Moves files on the Desktop named `Screenshot ...` / `Screen Shot ...` (png, jpg, jpeg, heic, tiff, gif, pdf, mov) into:

```
~/Desktop/Screenshots/YYYY/YYYY-MM-DD/
```

Folders are based on the file's creation date (via Spotlight metadata, falling back to `stat`). Duplicate names get a numeric suffix (`file 2.png`).

### `sort_desktop_mp4s_by_date.sh`
Moves `.mp4` / `.mov` files on the Desktop into:

```
~/Desktop/MP4s/YYYY/YYYY-MM-DD/
```

Same date logic and duplicate handling as above.

## Install

The LaunchAgents:

- `com.lukeligman.sort-screenshots-by-date.plist`
- `com.lukeligman.sort-desktop-mp4s-by-date.plist`

live in `~/Library/LaunchAgents/` and point `ProgramArguments` at these scripts (e.g. `~/.local/bin/sort_screenshots_by_date.sh`).

Load them with:

```sh
launchctl load ~/Library/LaunchAgents/com.lukeligman.sort-screenshots-by-date.plist
launchctl load ~/Library/LaunchAgents/com.lukeligman.sort-desktop-mp4s-by-date.plist
```

Logs are written to `~/Library/Logs/sort-*.log`.