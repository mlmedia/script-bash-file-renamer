#!/bin/bash
#         @(#) rename      1.0  25/02/2016       by Simon johansson
#                                         email: simonjohansson1985@hotmail.com
#
#         Initial version:  1.0  25/02/2016
#
#
replacedir () {
   count=0;
   for dir in *
   do
 		timestamp=$(date +%s)

	     if [ -d "$dir" ] ; then   # ==> if directory...
			 if [ -L "$dir" ] ; then   # ==> if dir is symbolic link...
           		echo "-------$dir" `ls -l $dir | sed 's/^.*'$dir' //'`
	   			# ==> dir for exeption of date and time 
        	 else
                # truncate to 40 characters to make room for appended timestamp if necessary
                truncateddir=${dir::40}
				newnamedir=`echo ${truncateddir} | tr [:upper:] [:lower:] | tr -c '[:alnum:]' '-' | tr ' ' '-' | tr -s '-'|sed 's/\-*$//'`

 				if [ "${newnamedir##$dir}" ] ;then
					if [ -e "$newnamedir" ] ;then
						((count++))
                        # append the timestamp and iterated number
                        renamedir=`echo ${newnamedir}-${timestamp}${count}`
                        mv -v "$dir" `echo $renamedir`
					else
						mv "$dir" `echo $newnamedir`
					fi
				fi

            	if cd "$newnamedir" ; then  # ==> if subdir is exist...
			   		#for file in $dir; do echo "$file"; done 
               		deep=`expr $deep + 1`   # ==> increase the deepth.
               		replacedir     # recursive call ;-)
               numdirs=`expr $numdirs + 1`   # ==> increase the count of dir.
			fi
         fi
      fi
   done
   cd ..   # ==> upward to parent directory.
   if [ "$deep" ] ; then  # ==> if depth = 0 return TRUE...
      swfi=1              # ==> the flag that the replacedir is complete
   fi
   deep=`expr $deep - 1`  # ==> decrease the deepth.
}

replacefile () {
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
                    if [ -f "$dir/$newname.$e" ]
                    then
                        ((i++))
                        # append the timestamp and iterated number
                        rename=`echo ${newname}-${timestamp}${i}`
                        mv -v "$file" `echo $dir/$rename.$e`
                    else
                        mv -v "$file" `echo $dir/$newname.$e`
                    fi
                fi
            fi
        done
 }

# - main function -
if [ $# != 2 ] ; then
   echo "No args !!!"    # ==> start in current directory if no arg.
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
swfi=0      # ==> replacedir exit flag.
deep=0      # ==> the deepth for show
numdirs=0

while [ "$swfi" != 1 ]   # if flag is unset...
do
   replacedir   # ==> first, replace the dir name
done
echo "counts of directory = $numdirs"

echo "start replace file in $2"

cd $2
   replacefile   # ==> second, replace the file name
exit 0


