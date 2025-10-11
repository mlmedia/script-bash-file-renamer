# Bash file renamer

This repository contains `renamer.sh`, a Bash script that creates a sanitized copy of a directory tree. The script first copies the source directory to a destination, then recursively renames every folder and file so the structure is safe for web hosting, S3 uploads, or other systems that dislike spaces and special characters.

## What the script does
- Copies the source directory to the destination without touching the original files.
- Normalizes directory names by lowercasing them, replacing spaces and special characters with single hyphens, trimming extras, and preserving symlinks.
- Normalizes file names and extensions using the same rules, truncates long basenames to 40 characters, and appends timestamps when duplicates are detected.

## Requirements
- Bash 4+ (tested on macOS and Linux).
- Standard Unix utilities (`cp`, `find`, `sed`, `tr`, `date`).

## Usage
1. Download `renamer.sh`.
2. Run the script with a source and destination directory:

   ```bash
   sh renamer.sh /path/to/source /path/to/destination
   ```

   The destination directory is created (or replaced) and populated with sanitized names.

### Example
Rename the sample files included in this repository:

```bash
sh renamer.sh ./sample_files ./renamed
```

### Windows line endings
If you edit the script on Windows, convert it back to Unix line endings before running:

```bash
dos2unix renamer.sh
```

Install `dos2unix` with `brew install dos2unix` (macOS) or `apt-get install dos2unix` (Ubuntu).
