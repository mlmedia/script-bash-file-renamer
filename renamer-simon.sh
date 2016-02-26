#!/bin/bash
# DESCRIPTION: This little project contains a shell script to copy a source directory and recursively rename all of the files in the directory in accordance with the following conventions.
# The default starting directory is the current directory.
###Directories##
#- all spaces are replaced with hyphens (e.g. My Directory/myfile.jpg -> My-Directory/myfile.jpg)

##Files##
#- all filenames are converted to lowercase letters (e.g. "MyFileName.doc" -> "myfilename.doc")
#- all file extensions are converted to lowercase letters (e.g. "myImage.JPG" -> "myimage.jpg")
#- all spaces are replaced with hyphens (e.g. "My Awesome Document with Spaces.pdf" -> "my-awesome-document-with-spaces.pdf")
#- all special characters are replaced with hyphens (e.g. "My_File~Wit#Spec!@lC#@racter5.txt" -> "my-file-wit-spec-lc-racter5.txt")
#- consecutive special characters or hyphens are converted to single hyphens (e.g. "My------Badly_________Named#######File.txt" -> "my-badly-named-file.txt")
#- duplicate files are appended with a timestamp and iterator to ensure no files are overwritten (e.g. "duplicate-file.jpg" -> "duplicate-file-12345654321.jpg")
#- all filenames are truncated to 40 characters

###Purpose###
#On desktop operating systems, spaces in files are not usually a problem.  When we use files on the web, spaces can become problematic.  For example, if you wanted to upload an entire directory of your music files to Amazon S3 for online file storage or usage via a custom cloud application, spaces can cause problems in links.  (e.g. http://www.mycloudmusicstorage.com/Awesome Band/Awesome Song.mp3).   

#This is not to say that there aren't work-arounds for file structures with spaces.  However, filenames and directories without spaces are safer and more standards-compliant (e.g. http://www.mycloudmusicstorage.com/awesome-band/awesome-song.mp3).

##Usage/Installation##
#1. Download / grab the renamer.sh file and place it anywhere on your computer
#2. Run the following script to rename all files in a directory:

# OPTIONS: see function 鈥檜sage鈥?below
# REQUIREMENTS: ---
# BUGS: ---
# NOTES: ---
# AUTHOR: Simon Johansson, simonjohansson1985@hotmail.com
# COMPANY: 
# VERSION: 1.0
# CREATED: 25.02.2016 - 12:36:50
# REVISION: 25.02.2016
#===================================================================================
match_double="--"
match_one="-"
max_namelen=40

# check if source dir exists
if [ -d $1 ] ;then

	# check for existence of destination dir argument
	if [ -n "$2" ] ;then

		# setup the destination directory
		if [ -d "$2" ] ;then
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
		if [ -d "$dir" ] ;then
			# replace spaces in directory names with underscores to avoid mv error
			newdir=`echo ${dir} | tr ' ' '-'`
			if [ "${newdir##$dir}" ] ;then
				mv "$dir" `echo $newdir`
			fi
		fi
		done

		# rename the files in the destination directory (source directory remains untouched)
		i=0;
		find . | while read file 
		do
		if [ -f "$file" ] ;then
			timestamp=$(date +%s)
			# truncate to 40 characters to make room for appended timestamp if necessary
			dir="${file%/*}"
			oldname="${file##*/}"
			truncated=${oldname::$max_namelen} 
			newname=$oldname
			# extract file name and path
			file_name="${newname%.*}" #extract the file name
			file_ext="${newname##*.}" #extract the file extension
			for reqsubstr in "~" "\." "\#" "\%" "'" " " "\!" "@" "\$" "\^" "\&" "\*" "(" ")" "{" "}" "[" "]" "|" "\?" "<" ">"
			do
				if [ -z "${file_name##*$reqsubstr*}" ] ;then
					file_name=${file_name//$reqsubstr/$match_one}
					count=1
					while [ $count -eq 1 ] 
					do # loop for replace "--" 2 "-"
						if [ -z "${file_name##*$match_double*}" ] ;then
							file_name=${file_name//$match_double/$match_one}
						else
							count=0
						fi
					done 
				fi
			done

			split="."
			newname=$file_name$split$file_ext
			newname="${newname,,}" #uppercase ^^
			trunknamelen=$(($max_namelen - ${#file_ext} - ${#split}))
			tmpfilename=$newname
			namelen=${#newname}
			#compare the filelen and pack to 40 char
			if [ $namelen -gt ${max_namelen} ] ;then
				trunknamelen=$(($max_namelen - ${#file_ext} - ${#split} - 1))
				tmpfilename=${newname:0:${trunknamelen}}
				tmpfilename=$tmpfilename$split$file_ext
			fi

			#check file is exist and add timestamp
			if [ -e "$dir/$tmpfilename" ] ;then
				trunknamelen=$(($max_namelen - ${#file_ext} - ${#split} - ${#timestamp}))
				tmpfilename=${tmpfilename:0:${trunknamelen}}
				tmpfilename=$tmpfilename$timestamp$split$file_ext
			fi

			newname=$tmpfilename
		
			if [ -e "$dir/$newname" ] ;then
				echo "file exit"
			else
				mv -v "$file" `echo $dir/$newname`
			fi

		fi #end of fie rename operation
		done
	else
			echo 'Destination directory not set'
	fi
else
		echo 'Source directory not found'
fi

