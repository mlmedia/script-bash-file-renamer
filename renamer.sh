#!/bin/bash

# check if source dir exists
if [ -d $1 ]
then

    # check for existence of destination dir argument
    if [ -n "$2" ]
    then

        # setup the destination directory (delete if it exists and create if it doesn't exist)
        if [ -d "$2" ]
        then
            rm -r $2
        fi
        mkdir -p $2

        # copy the entire directory
        cp -r $1 $2

        # rename the files in the destination directory (source directory remains untouched)
        cd $2
        ls -R $2 | while read -r FILE
        do
            if [ -f "$FILE" ]
            then
                mv -v "$FILE" $(echo $FILE | sed -e 's/[^A-Za-z0-9._-]/_/g' | tr '[A-Z]' '[a-z]')
                #mv -v "$FILE" `echo $FILE | tr ' ' '-' | tr '[A-Z]' '[a-z]' `
            fi
        done
    else
        echo 'Destination directory not set'
    fi
else
    echo 'Source directory not found'
fi
