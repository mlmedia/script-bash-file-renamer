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

        # loop through the files in the destination directory (source directory remains untouched)
        cd $2
        ls -R $2 | while read -r FILE
        do
            #mv -v "$FILE" echo $FILE | tr ' ' '_' | tr -d '[{}(),\!]' | tr -d "\'" | tr '[A-Z]' '[a-z]' | sed 's/_-_/_/g'
            echo $FILE;
        done
    else
        echo 'Destination directory not set'
    fi
else
    echo 'Source directory not found'
fi
