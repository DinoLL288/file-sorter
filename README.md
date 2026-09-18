# File Sorter

Two small scripts that keep your macOS Desktop tidy by automatically filing screenshots and screen recordings into date-organized folders.

## What happens when you download it

You get a folder (`file-sorter-vX.Y.Z`) containing three files:

| File | What it is |
| ---- | ---------- |
| `sort_screenshots_by_date.sh` | The script that sorts screenshots |
| `sort_desktop_mp4s_by_date.sh` | The script that sorts screen recordings |
| `README.md` | This file |

It does **not** change anything by itself. Nothing is installed, nothing runs, and your Desktop is untouched until you follow the setup steps below.

## How to use it

### 1. Download and unzip

1. On the **releases** page (https://github.com/DinoLL288/file-sorter/releases), click **file-sorter-vX.Y.Z.zip**.
2. If asked, confirm the Download button that appears (for a private repo, you must be the only visitor anyway — there's no extra login).
3. Double-click the downloaded `file-sorter-vX.Y.Z.zip` to unzip it.

### 2. Put the scripts in place

Open Terminal and run:

```sh
mkdir -p ~/.local/bin
mv ~/Downloads/file-sorter-vX.Y.Z/sort_screenshots_by_date.sh ~/.local/bin/
mv ~/Downloads/file-sorter-vX.Y.Z/sort_desktop_mp4s_by_date.sh ~/.local/bin/
chmod +x ~/.local/bin/sort_*.sh
```

(Use the actual version folder name, e.g. `file-sorter-v1.0.1`.)

### 3. Create the two LaunchAgents

These tell macOS to run the scripts every 10 seconds (or whenever something changes on your Desktop).

```sh
cat > ~/Library/LaunchAgents/com.lukeligman.sort-screenshots-by-date.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.lukeligman.sort-screenshots-by-date</string>
  <key>ProgramArguments</key>
  <array>
    <string>PLACEHOLDER_HOME/.local/bin/sort_screenshots_by_date.sh</string>
  </array>
  <key>WatchPaths</key>
  <array>
    <string>PLACEHOLDER_HOME/Desktop</string>
    <string>PLACEHOLDER_HOME/Desktop/Screenshots</string>
  </array>
  <key>StartInterval</key>
  <integer>10</integer>
</dict>
</plist>
EOF
```

Then replace `PLACEHOLDER_HOME` with your home folder:

```sh
sed -i '' 's|PLACEHOLDER_HOME|'"$HOME"'|g' ~/Library/LaunchAgents/com.lukeligman.sort-screenshots-by-date.plist
```

Repeat the same for the MP4 sorter:

```sh
cat > ~/Library/LaunchAgents/com.lukeligman.sort-desktop-mp4s-by-date.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.lukeligman.sort-desktop-mp4s-by-date</string>
  <key>ProgramArguments</key>
  <array>
    <string>PLACEHOLDER_HOME/.local/bin/sort_desktop_mp4s_by_date.sh</string>
  </array>
  <key>WatchPaths</key>
  <array>
    <string>PLACEHOLDER_HOME/Desktop</string>
  </array>
  <key>StartInterval</key>
  <integer>10</integer>
</dict>
</plist>
EOF
sed -i '' 's|PLACEHOLDER_HOME|'"$HOME"'|g' ~/Library/LaunchAgents/com.lukeligman.sort-desktop-mp4s-by-date.plist
```

### 4. Start it up

```sh
launchctl load ~/Library/LaunchAgents/com.lukeligman.sort-screenshots-by-date.plist
launchctl load ~/Library/LaunchAgents/com.lukeligman.sort-desktop-mp4s-by-date.plist
```

To make it stop on reboot? No — these are **LaunchAgents**, so macOS automatically starts them every time you log in. Logs are written to `~/Library/Logs/sort-*.log`.

### 5. What it does from then on

- Any file on your Desktop named `Screenshot ...` or `Screen Shot ...` (png, jpg, heic, tiff, gif, pdf, mov) gets moved into `~/Desktop/Screenshots/YYYY/YYYY-MM-DD/`.
- Any `.mp4` / `.mov` on your Desktop gets moved into `~/Desktop/MP4s/YYYY/YYYY-MM-DD/`.
- The date folder is based on when the file was taken (creation date), and name clashes get a suffix (`file 2.png`).

## Reverting

To uninstall:

```sh
launchctl unload ~/Library/LaunchAgents/com.lukeligman.sort-screenshots-by-date.plist
launchctl unload ~/Library/LaunchAgents/com.lukeligman.sort-desktop-mp4s-by-date.plist
rm ~/Library/LaunchAgents/com.lukeligman.sort-*.plist
rm ~/.local/bin/sort_*.sh
```

Your files are never deleted — folders are created on your Desktop and your screenshots/recordings stay there, just organized.

## For the curious: how the scripts work

- `sort_screenshots_by_date.sh` — by default sorts files named `Screenshot *` / `Screen Shot *` into `~/Desktop/Screenshots/YYYY/YYYY-MM-DD/`.
- `sort_desktop_mp4s_by_date.sh` — sorts `.mp4` / `.mov` files into `~/Desktop/MP4s/YYYY/YYYY-MM-DD/`.
- Both use Spotlight creation-date metadata (`mdls`) and fall back to `stat`. Duplicate names get a numeric suffix.