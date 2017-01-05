#!/bin/bash

if [ "$1" == "-r" ]
then
    echo "Are you sure you want to restart $HOSTNAME? (yes/no): "
else
    echo "Are you sure you want to shutdown $HOSTNAME? (yes/no): "
fi

read response

if [ "$response" != "yes" ]
then
    exit
fi

# pim
cd ~/pim
git add *
git commit -a -m "Automated commit from $HOSTNAME"
git push

# bash_profile and bashrc
cd ~/.config/termrc
git add *
git commit -a -m "Automated commit from $HOSTNAME"
git push

# vimrc
cd ~/.vim/vimrc
git add *
git commit -a -m "Automated commit from $HOSTNAME"
git push

# taskrc
task context none
task sync
cd ~/.task/taskrc
git add *
git commit -a -m "Automated commit from $HOSTNAME"
git push

# emacs
cd ~/.config/emacs/
git add *
git commit -a -m "Automated commit from $HOSTNAME"
git push

# i3
cd ~/.config/i3/i3rc
git add *
git commit -a -m "Automated commit from $HOSTNAME"
git push

if [ $1 == "-r" ]
then
    reboot
else
    poweroff
fi
