# Naming conventions

The renamer enforces predictable, web-friendly names for both directories and files.

## Directories
- Convert every directory name to lowercase letters (e.g. `MyDirectory` → `mydirectory`).
- Replace spaces with hyphens (e.g. `My Directory/myfile.jpg` → `my-directory/myfile.jpg`).
- Replace special characters with hyphens (e.g. `My_#1_Directory@My-computer` → `my-1-directory-my-computer`).
- Trim leading and trailing hyphens (e.g. `__MY_Directory###__` → `my-directory`).
- Collapse consecutive special characters or hyphens into single hyphens (e.g. `__My_Directory_with_#######_too-many_special-chars` → `my-directory-with-too-many-special-chars`).

## Files
- Convert filenames and extensions to lowercase letters (e.g. `MyFileName.DOC` → `myfilename.doc`).
- Replace spaces with hyphens (e.g. `My Awesome Document with Spaces.pdf` → `my-awesome-document-with-spaces.pdf`).
- Replace special characters with hyphens (e.g. `My_File~Wit#Spec!@lC#@racter5.txt` → `my-file-wit-spec-lc-racter5.txt`).
- Collapse consecutive special characters or hyphens into single hyphens (e.g. `My------Badly___Named#######File.txt` → `my-badly-named-file.txt`).
- Truncate filenames to 40 characters before adding conflict suffixes.
- Append a timestamp and iterator when duplicates appear so nothing is overwritten (e.g. `duplicate-file.jpg` → `duplicate-file-12345654321.jpg`).
