#!/bin/bash

# Git repositories to sync by default
declare -a default_repos=("~/pim"
                          "~/.config/termrc"
                          "~/.vim/vimrc"
                          "~/.task/taskrc"
                          "~/.config/emacs"
                          "~/.config/i3/i3rc")


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
printf "%s\n" "${default_repos[@]}" >> ~/.proj_dirs


while IFS= read -r line
do
    cd "$line"
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
