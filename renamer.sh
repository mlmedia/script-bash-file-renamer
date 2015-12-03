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
        find . -type f | while read f;
        do
            e="${f##*.}"
            temp="${f##*/}"
            newname=`echo ${temp%.*} | tr '@' '-' | tr '.' '-' | tr ' ' '-' | tr '[A-Z]' '[a-z]' `
            echo "orig: ${f}"
            echo "ext: ${e}"
            echo "temp: ${temp%.*}"
            echo "newname: ${newname}"
            #echo mv -v "$f" `echo $f | tr '@' '-' | tr '.' '-' | tr ' ' '-' | tr '[A-Z]' '[a-z]' `
        done
    else
        echo 'Destination directory not set'
    fi
else
    echo 'Source directory not found'
fi
