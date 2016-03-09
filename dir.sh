#!/bin/bash

# directory renaming function
rename_dir () {
    count=0;
    for dir in *
    do
        timestamp=$(date +%s)
        overlap=0
        if [ -d "$dir" ]
        then # ==> if directory...
            if [ -L "$dir" ] ; then   # ==> if dir is symbolic link...
                echo "-------$dir" `ls -l $dir | sed 's/^.*'$dir' //'`
                # ==> dir for exeption of date and time
            else
                # truncate to 40 characters to make room for appended timestamp if necessary
                truncateddir=${dir::40}
                newnamedir=`echo ${truncateddir} | tr [:upper:] [:lower:] | tr -c '[:alnum:]' '-' | tr ' ' '-' | tr -s '-'|sed 's/\-*$//'`
                if [[ $newnamedir != $dir && -d "$dir" ]]
                then
                    for match in $(find ./ -maxdepth 1 -type d)
                    do
                        pattern=`echo ${match##*./}`
                        if [[ "$pattern" = "$newnamedir" ]]
                        then
                            overlap=1
						fi
					done

                    if [ $overlap -lt 1 ]
                    then
                        mv -v "$dir" `echo $newnamedir`
					else
						((count++))
                        # append the timestamp and iterated number
                        newnamedir=`echo ${newnamedir}-${timestamp}${count}`
                        mv -v "$dir" `echo $newnamedir`
					fi
				fi
                if cd "$newnamedir"
                then  # ==> if subdir is exist...
                    #for file in $dir; do echo "$file"; done
                    deep=`expr $deep + 1`   # ==> increase the depth.
                    rename_dir     # recursive call ;-)
                    numdirs=`expr $numdirs + 1`   # ==> increase the count of dir.
                fi
            fi
        fi
    done

    cd ..   # ==> upward to parent directory.
    if [ "$deep" ]
    then  # ==> if depth = 0 return TRUE...
        swfi=1   # ==> the flag that the rename_dir is complete
    fi
    deep=`expr $deep - 1`  # ==> decrease the depth.
}

# file renaming function
rename_file () {
    countfile=0;
    find . | while read file;
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

						if [[ "$matchname" = "$rename" ]];then
							overlapfile=1
						fi
					done

				if [ $overlapfile -eq 0 ];then
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

# - main function -
if [ $# != 2 ]
then
    echo "No args !!!"    # ==> start in current directory if no arg.
    exit 0
else
    #cd $1       # ==> no move to indicated dir.
    # setup the destination directory
    if [ -d "$2" ]
    then
        rm -rf $2
    fi
    mkdir -p $2
    chmod -R 777 $2

    # copy the entire directory
    cp -r $1 $2
    cd $2
fi

echo "start replace directory in `pwd`"
swfi=0      # ==> rename_dir exit flag.
deep=0      # ==> the depth for show
numdirs=0

while [ "$swfi" != 1 ]   # if flag is unset...
do
   rename_dir   # ==> first, replace the dir name
done
echo "counts of directory = $numdirs"

echo "start replace file in $2"

cd $2
    rename_file   # ==> second, replace the file name
exit 0
