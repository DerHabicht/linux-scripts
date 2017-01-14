#!/bin/bash

source "$HOME/lib/thus_utils/default_repos.sh"

# Grab the hard-coded/default repositories
for repo in ${default_repos[@]}
do
    cd $repo
    printf "\nPulling `pwd`...\n"
    git pull
done

# Grab the repos in the active projects file
while IFS= read -r line
do
    cd "$line"
    printf "\nPulling `pwd`...\n"
    git pull
done < ~/.active_proj_dirs

uname -r | grep fc
if [[ $? == 0 ]]
then
    sudo dnf -y update
fi
