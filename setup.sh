#!/bin/bash

# THUS Utils
mkdir ~/bin
cd ~/bin
ln -s ~/lib/thus_utils/pom.sh pom
ln -s ~/lib/thus_utils/gzless.sh gzless
ln -s ~/lib/thus_utils/update.sh update

# bash_profile and bashrc
mkdir ~/.config/
cd ~/.config/
git clone git@git.the-hawk.us:misc/cfg/termrc.git
cd ~
ln -s .config/termrc/bash_profile .bash_profile
ln -s .config/termrc/bashrc .bashrc

# vimrc
mkdir ~/.vim
cd ~/.vim
git clone git@git.the-hawk.us:misc/cfg/vimrc.git
ln -s vimrc/autoload
ln -s vimrc/doc
ln -s vimrc/ftplugin
ln -s vimrc/plugin
ln -s vimrc/syntax
cd ~
ln -s .vim/vimrc/vimrc .vimrc
ln -s .vim/vimrc/vimrc .ideavimrc
ln -s .vim/vimrc/gvimrc .gvimrc

# taskrc
mkdir ~/.task
cd ~/.task
git clone git@git.the-hawk.us:misc/cfg/taskrc.git
cd ~
ln -s .task/taskrc/taskrc .taskrc

# i3
mkdir -p ~/.config/i3
cd ~/.config/i3
git clone git@git.the-hawk.us:misc/cfg/i3rc.git
ln -s i3rc/config

# timetrap
cd ~
ln -s Dropbox/databases/timetrap.db .timetrap.db
