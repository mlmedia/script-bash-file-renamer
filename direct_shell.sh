find . | while read f; do mv "$f" "`echo $f | tr -c '[:alnum:]' '-' | tr -s '-' | tr '[A-Z]' '[a-z]' | sed 's/\-*$//'`"; done

# rename the directories to remove whitespace (can cause errors)
find . | while read dir;
do
    if [ -d "$dir" ]
    then
        # replace spaces in directory names with underscores to avoid mv error
        newdir=`echo ${dir} | tr ' ' '-'`
        mv -v "$dir" `echo $newdir`
    fi
done

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

        # replace spaces in directory names with underscores to avoid mv error
        newdir=`echo ${dir} | tr ' ' '_'`
        echo "$newdir"

        # create the directory if it does not exist
        if [ ! -d $newdir ];
        then
            mkdir $newdir
        fi

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
                mv -v "$file" `echo $newdir/$rename.$e`
            else
                mv -v "$file" `echo $newdir/$newname.$e`
            fi
        fi
    fi
done
