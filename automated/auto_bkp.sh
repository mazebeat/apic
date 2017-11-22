#!/bin/bash

_current_dir='/z/apic'
_copy_to_dir='/c/Users/usuario/Projects/APIc'

_log="$_copy_to_dir/automated/copied.log"
_date=$(date +"%F %T")

echo "BACKUP $_date -----------" >> $_log
echo 'Finding modified or new files...' >> $_log
find ${_current_dir} -type f -not -path "*/WEB-INF/*" -mtime -1 -ls | awk '{print $11}' > "last_modified.log"

echo 'Init copy...' >> $_log
while read _file
do
    _file_to_copy=$(echo $_file| sed -e "s@$_current_dir@@g")
    echo "copying $_file_to_copy" >> $_log
    cp -fr "$_file" "$_copy_to_dir$_file_to_copy"
done < "last_modified.log" 

echo "End finding" >> $_log
echo . >> $_log