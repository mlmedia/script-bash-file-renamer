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
        i=0;
        find . | while read file;
        do
            timestamp=$(date +%s)
            if [ -f "$file" ]
            then
                e=`echo ${file##*.} | tr '[A-Z]' '[a-z]'`
                dir="${file%/*}"
                oldname="${file##*/}"
                truncated=${oldname::30}
                newname=`echo ${oldname%.*} | tr -c '[:alnum:]' '-' | tr -s '-' | tr '[A-Z]' '[a-z]' | sed 's/\-*$//'`
                if [ -f "$dir/$newname.$e" ]
                then
                    ((i++))
                    echo "$dir/$newname.$e"
                    # append the timestamp and iterated number
                    rename=`echo ${newname}-${timestamp}${i}`
                    mv -v "$file" `echo $dir/$rename.$e`
                else
                    mv -v "$file" `echo $dir/${newname}.$e`
                fi
                #echo "orig: ${file}"
                #echo "ext: ${e}"
                #echo "dir: ${dir}"
                #echo "oldname: ${oldname%.*}"
                #echo "newname: ${newname}"
                #mv -v "$file" `echo $dir/$newname.$e`
            fi
        done
    else
        echo 'Destination directory not set'
    fi
else
    echo 'Source directory not found'
fi
