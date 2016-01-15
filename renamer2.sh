#!/bin/bash

# check if source dir exists
if [ -d $1 ]
then

    # check for existence of destination dir argument
    if [ -n "$2" ]
    then

        # setup the destination directory
        if [ -d "$2" ]
        then
            rm -rf $2
        fi
        mkdir -p $2
        chmod -R 777 $2

        # copy the entire directory
        cp -r $1 $2

        # rename the directories to remove whitespace (can cause errors)
        cd $2
        find . | while read dir;
        do
            if [ -d "$dir" ]
            then
                # replace spaces in directory names with underscores to avoid mv error
                newdir=`echo ${dir} | tr -s '-'`
                mv "$dir" `echo $newdir`
            fi
        done

        # rename the files in the destination directory (source directory remains untouched)
        cd $2
        i=0;
        find . | while read file;
        do
            timestamp=$(date +%s)
            if [ -f "$file" ]
            then
                e=`echo ${file##*.} | tr '[A-Z]' '[a-z]'`
                dir="${file%/*}"
                oldname="${file##*/}"

                # truncate to 40 characters to make room for appended timestamp if necessary
                truncated=${oldname::40}
                newname=`echo ${truncated%.*} | tr -c '[:alnum:]' '-' | tr -s '-' | tr '[A-Z]' '[a-z]' | sed 's/\-*$//'`

                # check the length of the filename (skip files with no filename before the . like .DS_Store and .htaccess)
                len=$(echo ${#newname})
                if [ $len -gt 1 ]
                then
                    if [ -f "$olddir/$newname.$e" ]
                    then
                        ((i++))
                        #echo "$dir/$newname.$e"
                        # append the timestamp and iterated number
                        rename=`echo ${newname}-${timestamp}${i}`
                        mv -v "$file" `echo $dir/$rename.$e`
                    else
                        mv -v "$file" `echo $dir/$newname.$e`
                    fi
                fi
            fi
        done
    else
        echo 'Destination directory not set'
    fi
else
    echo 'Source directory not found'
fi
