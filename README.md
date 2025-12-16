# Bash file renamer

`renamer.sh` copies a directory tree to a new location and sanitizes every folder and file name along the way. It lowercases names, swaps spaces and special characters for single hyphens, trims extras, and adds timestamps when duplicates would collide—great for preparing files for the web, S3, or other strict environments.

## Features
- Leaves the source untouched while writing a normalized copy to the destination.
- Normalizes directories, filenames, and extensions with the same hyphenated, lowercase rules.
- Truncates long basenames and appends timestamps to keep duplicates unique.
- Works with standard Unix tools on macOS and Linux.

## Quick start
```bash
bash renamer.sh /path/to/source /path/to/destination
```

Try it with the included sample files:
```bash
bash renamer.sh ./sample_files ./renamed
```

If you edit the script on Windows, convert it back to Unix line endings before running:
```bash
dos2unix renamer.sh
```
