# Usage

Follow these steps to run the Bash file renamer, understand what it does, and learn how names are normalized in the sanitized copy.

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

## How it works
The renamer copies the source directory to a destination path and then normalizes every directory and file name within the copy. This keeps the original data intact while producing a version that is safe for web hosting, S3 uploads, or other systems that dislike spaces and special characters.

### Behavior
- Copies the source directory to the destination without touching the original files.
- Normalizes directory names by lowercasing them, replacing spaces and special characters with single hyphens, trimming extras, and preserving symlinks.
- Normalizes file names and extensions using the same rules, truncates long basenames to 40 characters, and appends timestamps when duplicates are detected.

## Naming conventions
The renamer enforces predictable, web-friendly names for both directories and files.

### Directories
- Convert every directory name to lowercase letters (e.g. `MyDirectory` → `mydirectory`).
- Replace spaces with hyphens (e.g. `My Directory/myfile.jpg` → `my-directory/myfile.jpg`).
- Replace special characters with hyphens (e.g. `My_#1_Directory@My-computer` → `my-1-directory-my-computer`).
- Trim leading and trailing hyphens (e.g. `__MY_Directory###__` → `my-directory`).
- Collapse consecutive special characters or hyphens into single hyphens (e.g. `__My_Directory_with_#######_too-many_special-chars` → `my-directory-with-too-many-special-chars`).

### Files
- Convert filenames and extensions to lowercase letters (e.g. `MyFileName.DOC` → `myfilename.doc`).
- Replace spaces with hyphens (e.g. `My Awesome Document with Spaces.pdf` → `my-awesome-document-with-spaces.pdf`).
- Replace special characters with hyphens (e.g. `My_File~Wit#Spec!@lC#@racter5.txt` → `my-file-wit-spec-lc-racter5.txt`).
- Collapse consecutive special characters or hyphens into single hyphens (e.g. `My------Badly___Named#######File.txt` → `my-badly-named-file.txt`).
- Truncate filenames to 40 characters before adding conflict suffixes.
- Append a timestamp and iterator when duplicates appear so nothing is overwritten (e.g. `duplicate-file.jpg` → `duplicate-file-12345654321.jpg`).

## Windows line endings
If you edit the script on Windows, convert it back to Unix line endings before running:

```bash
dos2unix renamer.sh
```

Install `dos2unix` with `brew install dos2unix` (macOS) or `apt-get install dos2unix` (Ubuntu).
