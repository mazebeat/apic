#!/bin/bash

_copy_to_dir='/c/Users/usuario/Projects/APIc'
_date=$(date +"%F %T")

cd $_copy_to_dir

git add -A
git commit -am "Commit $_date"
git push -u origin master