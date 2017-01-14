#!/bin/bash

source "$HOME/lib/thus_utils/default_repos.sh"

if [ "$1" == "-r" ]
then
    echo "Are you sure you want to restart $HOSTNAME? (yes/no): "
elif [ "$1" == "-d" ]
then
    echo "Simulate shutdown for $HOSTNAME? (yes/no): "
else
    echo "Are you sure you want to shutdown $HOSTNAME? (yes/no): "
fi

read response

if [ "$response" != "yes" ]
then
    exit
fi

# Sync Taskwarrior
task context none
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

if [ "$1" == "-r" ]
then
    reboot
elif [ "$1" == "-d" ]
then
    exit
else
    poweroff
fi
