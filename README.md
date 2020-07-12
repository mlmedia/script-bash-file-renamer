# File renamer script (Bash)
This little project contains a Bash shell script to non-destructively copy a source directory and recursively rename all directories and files in the destination directory.

## Purpose
Safety, consistency and tidiness.

On desktop operating systems, spaces in files are not usually a problem.  When we use files on the web, spaces can become problematic.  For example, if you wanted to upload an entire directory of your music files to Amazon S3 for online file storage or usage via a custom cloud application, spaces can cause problems in links.  (e.g. http://www.mycloudmusicstorage.com/Awesome Band/Awesome Song.mp3).   

This is not to say that there aren't work-arounds for file structures with spaces.  However, filenames and directories without spaces are safer and more standards-compliant (e.g. http://www.mycloudmusicstorage.com/awesome-band/awesome-song.mp3).

In short, it is safer and cleaner to have a directory full of consistently-named files rather than a hodge-podge of naming conventions with special characters and case-sensitivity issues.

## Naming conventions
### Directories
- all directories are converted to lowercase letters (e.g. "MyDirectory" -> "mydirectory")
- all spaces are replaced with hyphens (e.g. My Directory/myfile.jpg -> my-directory/myfile.jpg)
- all special characters are replaced with hyphens (e.g. "My_#1_Directory@My-computer -> "my-1-directory-my-computer")
- leading and trailing hyphens are trimmed (e.g. \_\_MY_Directory###\_\_ -> my-directory)
- consecutive special characters or hyphens are converted to single hyphens (e.g. "\_\_My\_Directory\_with\_#######\_too-many\_special-chars" -> "my-directory-with-too-many-special-chars")

### Files
- all filenames are converted to lowercase letters (e.g. "MyFileName.doc" -> "myfilename.doc")
- all file extensions are converted to lowercase letters (e.g. "myImage.JPG" -> "myimage.jpg")
- all spaces are replaced with hyphens (e.g. "My Awesome Document with Spaces.pdf" -> "my-awesome-document-with-spaces.pdf")
- all special characters are replaced with hyphens (e.g. "My_File~Wit#Spec!@lC#@racter5.txt" -> "my-file-wit-spec-lc-racter5.txt")
- consecutive special characters or hyphens are converted to single hyphens (e.g. "My------Badly\_\_\_Named#######File.txt" -> "my-badly-named-file.txt")
- duplicate files are appended with a timestamp and iterator to ensure no files are overwritten (e.g. "duplicate-file.jpg" -> "duplicate-file-12345654321.jpg")
- all filenames are truncated to 40 characters (prior to appending timestamp / iterator)

## Usage/Installation
1. Download / grab the renamer.sh file and place it anywhere on your computer
2. Run the following script to rename all files in a directory:

```bash
sh /PATH/TO/RENAMER/rename.sh PATH/TO/SOURCE/FILE/DIR/ PATH/TO/DESTINATION
```

## Example
Running the following script on the sample_files/ directory found in this application would be:

```bash
sh rename.sh ./sample_files ./renamed
```

### NOTE on switching between Linux/Unix and Windows
If running the script throws a "syntax error near unexpected token..." error message, it may be because Windows can change the encoding of the file if you have opened or edited it.  To fix this error, run DOS2UNIX:

- For Mac, install it with "brew install dos2unix")
- For Linux Ubuntu, install with "apt-get install dos2unix"
- Search for instructions on other operating systems
- Then use the command "dos2unix renamer.sh"

## Learn / Adopt / Fork
I try to use clear commenting to explain my code, so if you'd like to learn more, simply view the "renamer.sh" file.

Also, feel free to adopt and adapt to make it your own.  If you like, fork it and send over a pull request.  Add or solve existing issues.  It is open-source, after all.
