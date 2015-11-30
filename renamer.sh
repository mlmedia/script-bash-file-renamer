#!/bin/bash

# if the argument passed is an actual directory, continue
if [ -d $1 ]
then
    # go into target directory
    cd $1

    # setup the renamed files directory in current directory (for copied files)
    BACKUPDIR="renamed"
    if [ -d $1/$BACKUPDIR ]
    then
        rm -r $BACKUPDIR
    fi
    mkdir -p $BACKUPDIR

    # loop through the files in the directory
    ls -R $1 | while read -r FILE
    do
        #mv -v "$FILE" `echo $FILE | tr ' ' '_' | tr -d '[{}(),\!]' | tr -d "\'" | tr '[A-Z]' '[a-z]' | sed 's/_-_/_/g'`
        if [ -f "$FILE" ]
        then
            cp "$FILE" $1/$BACKUPDIR
            echo $FILE
        else
            echo 'Not a file - skipped'
        fi
    done
# else show error
else
    echo 'Directory not found'
fi
