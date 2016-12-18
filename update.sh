#!/bin/bash

cd ~/.vim/vimrc
git pull
cd ~/.task/taskrc
git reset --hard HEAD
git pull
cd ~/.config/termrc
git pull
cd ~/.config/i3/i3rc
git pull

uname -r | grep fc
if [[ $? == 0 ]]
then
    sudo dnf -y update
fi
