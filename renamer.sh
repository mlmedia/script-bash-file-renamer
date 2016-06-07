#!/bin/bash

# directory renaming function
renamedir(){
    count=0
    for dir in *
    do
        timestamp=$(date +%s)
        overlap=0

        # if the file is a directory
        if [ -d "$dir" ]
        then
            # if dir is symbolic link
            if [ -L "$dir" ]
            then
                echo "-------$dir" `ls -l $dir | sed 's/^.*'$dir' //'`
            else
                # else rename the directory
                # truncate to 40 characters to make room for appended timestamp if necessary
                truncated=${dir::40}
                newname=`echo ${truncated} | tr [:upper:] [:lower:] | tr -c '[:alnum:]' '-' | tr ' ' '-' | tr -s '-'| sed 's/\-*$//'`
                tempname=`echo ${newname}-temp`

                # set up and use a temp name to get through issue with case insensitivity renames to same name
                tempname=`echo ${newname}-temp`
                if [[ -d "$dir" ]]
                then
                    if [[ $dir != $newname ]]
                    then
                        # copy and delete instead of using "mv" to preserve metadata with -p flag
                        cp -rp "$dir" `echo $tempname`
                        rm -rf "$dir"
                        cp -rp "$tempname" `echo $newname`
                        rm -rf "$tempname"
                        echo "directory renamed to $newname"
                        numdirs=`expr $numdirs + 1`
                    fi

                    # iterate the count
					((count++))
				fi

                # CD into the renamed directory to check for subdirectories
                if cd "$newname"
                then
                    # increase the depth
                    # then recursively call the renamedir function
                    # finally iterate +1 on the dir counter
                    depth=`expr $depth + 1`
                    renamedir
                fi
            fi
        fi
    done

    # switch to parent directory
    cd ..

    # if depth = 0, set the finish_flag to 1 (true)
    if [ "$depth" ]
    then
        # flag that the renamedir function is complete
        finish_flag=1
    fi

    # decrease the depth after CD
    depth=`expr $depth - 1`
}

# file renaming function
rename_file(){
    countfile=0
    renamed_files=0

    # nesting the while loop so the renamed_files count can be passed outside it
    find . | \
    {
        while read file
        do
            timestamp=$(date +%s)
            overlapfile=0
            if [ -f "$file" ]
            then
                e=`echo ${file##*.} | tr '[A-Z]' '[a-z]'`
                dir="${file%/*}"
                oldname="${file##*/}"

                # truncate to 40 characters to make room for appended timestamp if necessary
                truncated=${oldname::40}
                newname=`echo ${truncated%.*} | tr -c '[:alnum:]' '-' | tr -s '-' | tr '[A-Z]' '[a-z]' | sed 's/\-*$//'`
                tempname=`echo ${newname}-temp`

                # check the length of the filename (skip files with no filename before the . like .DS_Store and .htaccess)
                len=$(echo ${#newname})
    			rename=`echo ${newname}.${e}`

                if [[ $len -gt 1 && $rename != $oldname ]]
                then
                   	for matchfile in $(find $dir -maxdepth 1 -type f)
    				do
            			matchname="${matchfile##*/}"

    					if [[ "$matchname" = "$rename" ]]
                        then
    						overlapfile=1
    					fi
    				done

                    # give the file a temp name to avoid same name problem
                    cp -p "$file" `echo $dir/$tempname.$e`
                    rm -f "$file"

    				if [ $overlapfile -eq 0 ]
                    then
                        if [[ $tempname != $newname ]]
                        then
                            # copy and delete instead of using "mv" to preserve metadata with -p flag
                            cp -p "$dir/$tempname.$e" `echo $dir/$newname.$e`
                            rm -f "$dir/$tempname.$e"
                            echo "file renamed to $dir/$newname.$e"

                            # iterate the file renamed counter
                            ((renamed_files++))
                        fi
    				else
                        # iterate the file renamed counter
                        ((renamed_files++))

                        # iterate the file count for renaming purposes
    					((countfile++))

                        # append the timestamp and iterated number
                        rename=`echo ${newname}-${timestamp}${countfile}`

                        # copy and delete instead of using "mv" to preserve metadata with -p flag
                        cp -p "$dir/$tempname.$e" `echo $dir/$rename.$e`
                        rm -f "$dir/$tempname.$e"
                        echo "file renamed to $dir/$rename.$e"
    				fi
                fi
            fi
        done

        # give a little more feedback to the command line
        echo "files renamed: $renamed_files"
    }
}

# primary loop
if [ $# != 2 ]
then
    echo "ERROR: both source and destination directories need to be passed as arguments (e.g. \"sh renamer.sh /PATH/TO/SOURCE/ /PATH/TO/DESTINATION\")"
    exit 0
else
    # check if source dir exists, otherwise pass error message
    if [ ! -d $1 ]
    then
        echo "ERROR: source directory \"$1\" does not exist"
        exit 0
    fi

    # setup the destination directory
    if [ -d "$2" ]
    then
        rm -rf $2
    fi
    mkdir -p $2
    # chmod -R 777 $2

    # copy the entire directory
    cp -rp $1 $2
    cd $2
fi

echo "replacing directories in `pwd`"

# set the default values for the vars
finish_flag=0
depth=0
numdirs=0

 # while the finish flag is unset, run the renamedir function
while [ "$finish_flag" != 1 ]
do
    renamedir
done

# give a little feedback to the command line
echo "directories renamed: $numdirs"
echo "starting to replace files in: $2"

# fire the rename_file function when the renamedir function is done
cd $2
    rename_file
exit 0
