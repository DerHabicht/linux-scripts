#!/bin/bash

remote_dir=$1
repo_dir=$2

# Verify the command was executed correctly
if [ "$remote_dir" == "" ]
then
    echo "Usage: rinit [REMOTE_DIR] {[REPO_DIR]}"
    exit
fi

if [ "$repo_dir" == "" ]
then
    repo_dir=`pwd`
fi

rdir=$(basename $repo_dir)
# Test for the existence of the directory
cd $repo_dir
if [ $? != 0 ]
then
    exit
fi

# Test for the existence of a repository
git status > /dev/null
if [ $? != 0 ]
then
    exit
fi

# Remember current stderr handler, then set stderr to /dev/null
exec 3>&2
exec 2> /dev/null

# Initialize origin
git remote | grep "origin" > /dev/null
if [ $? != 0 ]
then
    echo "Configuring origin..."
    git remote add origin "git@git.the-hawk.us:$remote_dir/$rdir.git" > /dev/null

    git fetch > /dev/null
    if [ $? != 0 ]
    then
        echo "Uploading bare repo to origin..."
        cd ..
        git clone --bare $repo_dir > /dev/null
        scp -r "$repo_dir.git" "git@git.the-hawk.us:$remote_dir/" > /dev/null
        rm -rf "$repo_dir.git"
        cd $repo_dir
        git fetch > /dev/null
        if [ $? == 0 ]
        then
            printf "$(tput setaf 2)"
            echo "Successfully added bare repo to origin."
            printf "$(tput sgr0)"
            git branch -u origin/master master
        else
            printf "$(tput setaf 1)"
            echo "Failed to add bare repo to origin."
            printf "$(tput sgr0)"
        fi
    fi
    printf "$(tput setaf 2)"
    echo "Origin configured."
    printf "$(tput sgr0)"
else
    printf "$(tput setaf 2)"
    echo "Origin already configured."
    printf "$(tput sgr0)"
fi

# Restore the stderr handler
exec 2>&3
