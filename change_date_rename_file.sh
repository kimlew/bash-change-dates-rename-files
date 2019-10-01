#! /usr/bin/env bash
#
# Name: change_dates_rename_files.sh
#
# Brief: Command-line Bash script to change Creation Date & Modified Date that  
# are currently download date to photo-taken date. The script also adds
# photo-taken date to the filename. These changes will make file sorting  
# easier. Takes in 1 command-line parameter, directory_path, the location of 
# the files.
#
# Note: Photo-taken date is exif:DateTimeOriginal.
# Note: Script processes only a single directory. 
#
# Author: Kim Lew

echo "Type the directory path for the files that need changed dates & filenames: "
read directory_path
echo "You typed: " $directory_path

if [ ! -d $directory_path ] 
then
    echo "This directory does NOT exist." 
    exit 9999 # die with error code 9999
fi

echo "Date changes and filename changes in progress..."
echo "..."

# Loop that processes entire given directory.
find $directory_path -type f |
while read a_file_name; do
  ### Filesystem/OS Date Change ###
  # Change filesystem date to EXIF photo-taken date, EXIF:DateTimeOriginal.
  # Save command chain output in variable, date_for_date_change.
  date_for_date_change=$(identify -format '%[EXIF:DateTimeOriginal]' \
  $a_file_name \
  | sed -e 's/://g' -e 's/ //g' -E -e 's/(..)$/\.\1/')

  # Test with: echo touch -t $date_for_date_change $directory_path/$file_name
  touch -t $date_for_date_change $a_file_name

  ### Filename Change that includes Date ###
  # Use EXIF photo-taken date, EXIF:DateTimeOriginal, change format & use in filename.
  # Save command chain output in variable, date_for_filename_change.
  date_for_filename_change=$(identify -format '%[EXIF:DateTimeOriginal]' \
  $a_file_name \
  | sed -e 's/.\{3\}$//' -e 's/:/-/g' -e 's/ /_/g')

  # Replace IMG_ in filename with value in $datestring_for_filename, which is
  # in the format: YYYY-MM-DD_HH-MM, e.g., 2016-01-27_08-15.
  new_file_name=$(echo "$a_file_name" | sed "s/IMG/$date_for_filename_change/")
  mv $a_file_name $new_file_name 

done
echo "Done."

exit 0
