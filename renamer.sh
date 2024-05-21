#!/bin/bash

# Function to rename directories
rename_dirs() {
	count=0
	for dir in *; do
		timestamp=$(date +%s)
		overlap=0

		if [ -d "$dir" ]; then
			if [ -L "$dir" ]; then
				echo "-------$dir $(ls -l "$dir" | sed "s/^.*$dir //")"
			else
				truncated=${dir:0:40}
				newname=$(echo "$truncated" | tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]' '-' | tr ' ' '-' | tr -s '-' | sed 's/\-*$//')
				tempname="${newname}-temp"

				if [ -d "$dir" ]; then
					if [ "$dir" != "$newname" ]; then
						((num_dirs_renamed++))
						cp -rp "$dir" "$tempname"
						rm -rf "$dir"
						cp -rp "$tempname" "$newname"
						rm -rf "$tempname"
						echo "directory $dir renamed to $newname"
					else
						((num_dirs_unchanged++))
						echo "directory $dir unchanged"
					fi
					((count++))
				fi

				if cd "$newname"; then
					((depth++))
					rename_dirs
					cd ..
					((depth--))
				fi
			fi
		fi
	done

	if [ "$depth" -eq 0 ]; then
		finish_flag=1
	fi
}

# Function to rename files
rename_files() {
	countfile=0
	num_files_renamed=0
	num_files_unchanged=0

	find . -type f | while read -r file; do
		timestamp=$(date +%s)
		overlapfile=0
		e=$(echo "${file##*.}" | tr '[A-Z]' '[a-z]')
		dir="${file%/*}"
		oldname="${file##*/}"

		truncated=${oldname:0:40}
		newname=$(echo "${truncated%.*}" | tr -c '[:alnum:]' '-' | tr -s '-' | tr '[A-Z]' '[a-z]' | sed 's/\-*$//')
		tempname="${newname}-temp"

		shortnew=${newname:0:28}
		shortnewname=$(echo "${shortnew%.*}" | tr -c '[:alnum:]' '-' | tr -s '-' | tr '[A-Z]' '[a-z]' | sed 's/\-*$//')

		len=${#newname}
		rename="${newname}.${e}"

		if [[ $len -gt 1 && $rename != $oldname ]]; then
			for matchfile in "$dir"/*; do
				matchname="${matchfile##*/}"
				if [[ "$matchname" == "$rename" ]]; then
					overlapfile=1
				fi
			done

			cp -p "$file" "$dir/$tempname.$e"
			rm -f "$file"

			if [ $overlapfile -eq 0 ]; then
				cp -p "$dir/$tempname.$e" "$dir/$newname.$e"
				rm -f "$dir/$tempname.$e"
				echo "file renamed to $dir/$newname.$e"
				((num_files_renamed++))
			else
				((num_files_renamed++))
				((countfile++))
				rename="${shortnewname}-${timestamp}${countfile}"
				cp -p "$dir/$tempname.$e" "$dir/$rename.$e"
				rm -f "$dir/$tempname.$e"
				echo "file renamed to $dir/$rename.$e"
			fi
		else
			echo "file $file unchanged"
			((num_files_unchanged++))
		fi
	done

	echo "..."
	echo "FILE RENAME COMPLETE"
	echo "files renamed: $num_files_renamed"
	echo "files unchanged: $num_files_unchanged"
	echo "...\n..."
	echo "SCRIPT COMPLETE"
}

# Main script logic
if [ $# -ne 2 ]; then
	echo "ERROR: both source and destination directories need to be passed as arguments (e.g. \"sh renamer.sh /PATH/TO/SOURCE/ /PATH/TO/DESTINATION\")"
	exit 1
else
	if [ ! -d "$1" ]; then
		echo "ERROR: source directory \"$1\" does not exist"
		exit 1
	fi

	if [ -d "$2" ]; then
		rm -rf "$2"
	fi
	mkdir -p "$2"

	echo "STARTING to copy $1 to $2"
	cp -rp "$1" "$2"
	echo "..."
	echo "COPY COMPLETE"
	echo "...\n..."

	cd "$2"
fi

echo "STARTING to rename directories in $(pwd)"
echo "..."

finish_flag=0
depth=0
num_dirs_renamed=0
num_dirs_unchanged=0

while [ "$finish_flag" -ne 1 ]; do
	rename_dirs
done

echo "..."
echo "DIRECTORY RENAME COMPLETE"
echo "directories renamed: $num_dirs_renamed"
echo "directories unchanged: $num_dirs_unchanged"
echo "...\n..."
echo "STARTING to rename files in: $2"
echo "..."

cd "$2"
rename_files

exit 0
