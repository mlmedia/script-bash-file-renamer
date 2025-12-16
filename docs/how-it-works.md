# How it works

The renamer copies the source directory to a destination path and then normalizes every directory and file name within the copy. This keeps the original data intact while producing a version that is safe for web hosting, S3 uploads, or other systems that dislike spaces and special characters.

## Behavior
- Copies the source directory to the destination without touching the original files.
- Normalizes directory names by lowercasing them, replacing spaces and special characters with single hyphens, trimming extras, and preserving symlinks.
- Normalizes file names and extensions using the same rules, truncates long basenames to 40 characters, and appends timestamps when duplicates are detected.
