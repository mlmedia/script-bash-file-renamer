#!/bin/bash

# Ensure the script is executed with Bash even if invoked with `sh`.
if [ -z "$BASH_VERSION" ]; then
	if command -v bash >/dev/null 2>&1; then
		exec bash "$0" "$@"
	else
		echo "ERROR: This script requires Bash, but it was not run with Bash." >&2
		exit 1
	fi
fi

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
				newname=$(echo "$truncated" | tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]' '-' | tr ' ' '-' | tr -s '-' | sed 's/^-*//' | sed 's/\-*$//')
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

	tmpfile=$(mktemp)
        find . -type f -print0 >"$tmpfile"

        while IFS= read -r -d '' file; do
                timestamp=$(date +%s)
                overlapfile=0
                dir="${file%/*}"
                oldname="${file##*/}"

                # Skip any files that live inside hidden directories (paths containing
                # a component that begins with a dot) so that metadata folders such as
                # .git or macOS resource directories remain untouched.
                if [[ "$file" == */.* ]]; then
                        ((num_files_unchanged++))
                        continue
                fi

                truncated=${oldname:0:40}

                # Skip hidden files that begin with a dot (e.g., .DS_Store, .htaccess)
                # to avoid generating renamed copies of metadata files.
                if [[ "$oldname" == .* && "$oldname" != "." && "$oldname" != ".." ]]; then
                        ((num_files_unchanged++))
                        continue
                fi

                if [[ "$oldname" == *.* && "$oldname" != .* ]]; then
			base="${truncated%.*}"
			extension=$(echo "${oldname##*.}" | tr '[:upper:]' '[:lower:]')
		else
			base="$truncated"
			extension=""
		fi

		sanitized_base=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr '.' '-' | tr -c '[:alnum:]' '-' | tr -s '-')
		newname=$(echo "$sanitized_base" | sed 's/^-*//' | sed 's/\-*$//')
		tempname="${newname}-temp"

		shortnew=${newname:0:28}
		shortnewname=$(echo "$shortnew" | tr '.' '-' | tr -c '[:alnum:]' '-' | tr -s '-' | tr '[:upper:]' '[:lower:]' | sed 's/^-*//' | sed 's/\-*$//')

		len=${#newname}

		if [ -n "$extension" ]; then
			target_name="${newname}.${extension}"
			temp_file="$dir/$tempname.$extension"
		else
			target_name="$newname"
			temp_file="$dir/$tempname"
		fi

		if [[ $len -gt 1 && $target_name != "$oldname" ]]; then
			for matchfile in "$dir"/*; do
				matchname="${matchfile##*/}"
				if [[ "$matchname" == "$target_name" ]]; then
					overlapfile=1
				fi
			done

			cp -p "$file" "$temp_file"
			rm -f "$file"

			if [ $overlapfile -eq 0 ]; then
				final_path="$dir/$target_name"
				cp -p "$temp_file" "$final_path"
				rm -f "$temp_file"
				echo "file renamed to $final_path"
				((num_files_renamed++))
			else
				((num_files_renamed++))
				((countfile++))
				target_name="${shortnewname}-${timestamp}${countfile}"
				if [ -n "$extension" ]; then
					final_path="$dir/$target_name.$extension"
				else
					final_path="$dir/$target_name"
				fi
				cp -p "$temp_file" "$final_path"
				rm -f "$temp_file"
				echo "file renamed to $final_path"
			fi
		else
			((num_files_unchanged++))
		fi
	done <"$tmpfile"

	rm -f "$tmpfile"

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

rename_files

exit 0
