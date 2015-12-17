#File renamer (shell)#
This litte project contains a shell script to copy a source directory and recursively rename all of the files in the directory in accordance with the following convention:
- all special characters are replaced with hyphens (e.g. "My_File~Wit#Spec!@lC#@racter5.txt" -> "my-file-wit-spec-lc-racter5.txt")
- all spaces are replaced with hyphens (e.g. "My Awesome Document with Spaces.pdf" -> "my-awesome-document-with-spaces.pdf")
- consecutive special characters or hyphens are converted to single hyphens (e.g. "My------Badly_________Named#######File.txt" -> "my-badly-named-file.txt")
- all filenames are converted to lowercase letters (e.g. "MyFileName.doc" -> "myfilename.doc")
- all file extensions are converted to lowercase letters (e.g. "myImage.JPG" -> "myimage.jpg")
- duplicate files are appended with a timestamp and iterator to ensure no files are overwritten (e.g. "duplicate-file.jpg" -> "duplicate-file-12345654321.jpg")
- filenames are truncated to 40 characters

##Usage/Installation##
1. Download / grab the renamer.sh file and place it anywhere on your computer
2. Run the following script to rename all files in a directory:

```bash
sh rename.sh PATH/TO/SOURCE/FILE/DIR/ PATH/TO/DESTINATION
```

##Example###
Running the following script on the sample_files/ directory found in this application would be:

```bash
sh rename.sh ./sample_files ./backup
```

##Learn / Adopt / Fork##
I try to use clear commenting to explain my code, so if you'd like to learn more, simply view the "renamer.sh" file.

Also, feel free to adopt and adapt to make it your own.  If you like, fork it and send over a pull request.  Add or solve existing issues.  It is open-source, after all.
