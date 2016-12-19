#!/bin/bash

# THUS Utils
mkdir ~/bin
ln -s ~/lib/thus_utils/pom.sh ~/bin/pom
ln -s ~/lib/thus_utils/gzless.sh ~/bin/gzless
ln -s ~/lib/thus_utils/update.sh ~/bin/update

# bash_profile and bashrc
mkdir ~/.config/
git clone git@git.the-hawk.us:misc/cfg/termrc.git ~/.config/termrc
ln -s .config/termrc/bash_profile ~/.bash_profile
ln -s .config/termrc/bashrc ~/.bashrc

# vimrc
mkdir ~/.vim
git clone git@git.the-hawk.us:misc/cfg/vimrc.git ~/.vim/vimrc
ln -s vimrc/autoload
ln -s vimrc/doc
ln -s vimrc/ftplugin
ln -s vimrc/plugin
ln -s vimrc/syntax
ln -s .vim/vimrc/vimrc ~/.vimrc
ln -s .vim/vimrc/vimrc ~/.ideavimrc
ln -s .vim/vimrc/gvimrc ~/.gvimrc

# taskrc
mkdir ~/.task
git clone git@git.the-hawk.us:misc/cfg/taskrc.git ~/.task/taskrc
ln -s .task/taskrc/taskrc ~/.taskrc

# i3
mkdir -p ~/.config/i3
git clone git@git.the-hawk.us:misc/cfg/i3rc.git ~/.config/i3/i3rc
ln -s i3rc/config

# timetrap
ln -s Dropbox/databases/timetrap.db ~/.timetrap.db
