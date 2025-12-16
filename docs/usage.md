# Usage

Follow these steps to run the Bash file renamer and create a sanitized copy of a directory tree.

## Requirements
- Bash 4+ (tested on macOS and Linux)
- Standard Unix utilities (`cp`, `find`, `sed`, `tr`, `date`)

## Running the script
1. Download or clone this repository to access `renamer.sh`.
2. Run the script with a source and destination directory:

   ```bash
   bash renamer.sh /path/to/source /path/to/destination
   ```

   The destination directory is created (or replaced) and populated with sanitized names. The source directory is left untouched.

## Example
Rename the sample files included in this repository:

```bash
bash renamer.sh ./sample_files ./renamed
```

## Windows line endings
If you edit the script on Windows, convert it back to Unix line endings before running:

```bash
dos2unix renamer.sh
```

Install `dos2unix` with `brew install dos2unix` (macOS) or `apt-get install dos2unix` (Ubuntu).
