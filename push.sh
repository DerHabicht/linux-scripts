#!/bin/bash

source "$HOME/lib/thus_utils/default_repos.sh"

# Sync Taskwarrior
task sync

# Sync relevant Git repositories
cat ~/.active_proj_dirs >> ~/.proj_dirs
printf "%s\n" "${default_repos[@]}" >> ~/.proj_dirs


while IFS= read -r line
do
    cd "$line"
    printf "\nCommitting `pwd`...\n"
    git add *
    git commit -a -m "Automated commit from $HOSTNAME"
    git push
done < ~/.proj_dirs

rm ~/.proj_dirs
