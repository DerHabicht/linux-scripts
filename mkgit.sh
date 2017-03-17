#!/bin/bash

mkdir "$2"

if [ $? -ne 0 ]
then
    echo "Unable to create directory $2"
    exit
fi

cd "$2"
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

if [ "$4" == "byui" ]
then
    source $HOME/.ssh/byuill.sh
    cd ..
    scpp -P 215 -r "$2.git" "thehawk@byuill:repos/"
    cd "$2"
    git remote add submit "ssh://thehawk@byuill:215/~/repos/$2.git"
    gitp fetch submit

    if [ $? -ne 0 ]
    then
        echo "Failed to push $2 to BYU-I LinuxLab"
        exit
    fi
fi

register "$1"
cd ..
rm -rf "$2".git
