#!/bin/bash

# directory renaming function
rename_dir () {
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

                # set up and use a temp name to get through issue with case insensitivity renames to same name
                tempname=`echo ${newname}-temp`
                if [[ -d "$dir" ]]
                then
                    mv -v "$dir" `echo $tempname`
                    mv -v "$tempname" `echo $newname`

                    # iterate the count
					((count++))
				fi

                #if [[ $newname != $dir && -d "$dir" ]]
                #then
                #    for match in $(find ./ -maxdepth 1 -type d)
                #    do
                #        pattern=`echo ${match##*./}`
                #        if [[ "$pattern" = "$newname" ]]
                #        then
                #            overlap=1
				#		fi
				#	done

                #    if [ $overlap -lt 1 ]
                #    then
                #        mv -v "$dir" `echo $newname`
				#	else
                        # append the timestamp and iterated number
				#		((count++))
                #        newname=`echo ${newname}-${timestamp}${count}`
                #        mv -v "$dir" `echo $newname`
				#	fi
				#fi

                # CD into the renamed directory to check for subdirectories
                if cd "$newname"
                then
                    # increase the depth
                    # then recursively call the rename_dir function
                    # finally iterate +1 on the dir counter
                    depth=`expr $depth + 1`
                    rename_dir
                    numdirs=`expr $numdirs + 1`
                fi
            fi
        fi
    done

    # switch to parent directory
    cd ..

    # if depth = 0, set the finish_flag to 1 (true)
    if [ "$depth" ]
    then
        # flag that the rename_dir function is complete
        finish_flag=1
    fi

    # decrease the depth after CD
    depth=`expr $depth - 1`
}

# file renaming function
rename_file () {
    countfile=0
    find . | while read file
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

				if [ $overlapfile -eq 0 ]
                then
					 mv -v "$file" `echo $dir/$newname.$e`
				else
					((countfile++))
                    # append the timestamp and iterated number
                    rename=`echo ${newname}-${timestamp}${countfile}`
                    mv -v "$file" `echo $dir/$rename.$e`
				fi
            fi
        fi
    done
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
    cp -r $1 $2
    cd $2
fi

echo "replacing directories in `pwd`"

# set the default values for the vars
finish_flag=0
depth=0
numdirs=0

 # while the finish flag is unset, run the rename_dir function
while [ "$finish_flag" != 1 ]
do
   rename_dir
done

# give a little feedback to the command line
echo "directory count: $numdirs"
echo "starting to replace files in: $2"

# fire the rename_file function when the rename_dir function is done
cd $2
    rename_file
exit 0
