#!/bin/bash

# USAGE: mkgit PATH REPO_NAME REM_DIR
if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ]
then
    echo "Usage: mkgit [PATH] [REPO_NAME] [REM_DIR]"
    exit
fi

cd "$2"

if [ $? -ne 0 ]
then
    mkdir "$2"

    if [ $? -ne 0 ]
    then
        echo "Unable to create directory $2"
        exit
    fi

    cd "$2"
fi

git init
echo "INITIAL COMMIT" > README.md
git add README.md
git commit -m "Initial commit"
cd ..
git clone --bare $2
scp -r "$2".git "git@git.the-hawk.us:$3/"
cd "$2"
git remote add origin "git@git.the-hawk.us:$3/$2.git"
git fetch

if [ $? -ne 0 ]
then
    echo "Failed to push $2 to THUS git"
    exit
fi

git branch -u origin/master master

register -r "$1/$2"
cd ..
rm -rf "$2".git
