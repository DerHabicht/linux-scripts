#!/bin/bash

if [ "$1" == "" ]
then
    echo "Please provide a project name."
    exit
fi

mkdir "$HOME/devel/prog/$1"
if [ "$?" != "0" ]
then
    echo "The directory name $1 is already in use."
    exit
fi

cd "$HOME/devel/prog/$1"

curl https://raw.githubusercontent.com/github/gitignore/master/Python.gitignore > .gitignore
curl https://raw.githubusercontent.com/github/choosealicense.com/gh-pages/_licenses/mit.txt > LICENSE
curl https://gist.githubusercontent.com/PurpleBooth/109311bb0361f32d87a2/raw/8254b53ab8dcb18afc64287aaddd9e5b6059f880/README-Template.md > README.md

python3 -m venv venv --prompt "$1"
source "$HOME/devel/prog/$1/venv/bin/activate"
pip freeze > requirements.txt
deactivate

git init
git add .gitignore
git add LICENSE
git add README.md
git add requirements.txt
git commit -m "Initial commit"
git flow init
