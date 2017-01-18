#!/bin/bash

# THUS Utils
mkdir ~/bin
ln -s ~/lib/thus_utils/pom.sh ~/bin/pom
ln -s ~/lib/thus_utils/update.sh ~/bin/update
ln -s ~/lib/thus_utils/off.sh ~/bin/off
ln -s ~/lib/thus_utils/notify.sh ~/bin/notify
ln -s ~/lib/thus_utils/register.sh ~/bin/register
ln -s ~/lib/thus_utils/today.sh ~/bin/today
ln -s ~/lib/thus_utils/start.sh ~/bin/start
ln -s ~/lib/thus_utils/stop.sh ~/bin/stop
ln -s ~/lib/thus_utils/finish.sh ~/bin/finish
ln -s ~/lib/thus_utils/home.sh ~/bin/home
ln -s ~/lib/thus_utils/school.sh ~/bin/school
ln -s ~/lib/thus_utils/work.sh ~/bin/work

# bash_profile and bashrc
mkdir ~/.config/
git clone git@git.the-hawk.us:misc/cfg/termrc.git ~/.config/termrc
ln -s ~/.config/termrc/bash_profile ~/.bash_profile
ln -s ~/.config/termrc/bashrc ~/.bashrc

# vimrc
mkdir ~/.vim
git clone git@git.the-hawk.us:misc/cfg/vimrc.git ~/.vim/vimrc
ln -s ~/.vim/vimrc/autoload ~/.vim/autoload
ln -s ~/.vim/vimrc/doc ~/.vim/doc
ln -s ~/.vim/vimrc/ftplugin ~/.vim/ftplugin
ln -s ~/.vim/vimrc/plugin ~/.vim/plugin
ln -s ~/.vim/vimrc/syntax ~/.vim/syntax
ln -s ~/.vim/vimrc/vimrc ~/.vimrc
ln -s ~/.vim/vimrc/vimrc ~/.ideavimrc
ln -s ~/.vim/vimrc/gvimrc ~/.gvimrc

# taskrc
mkdir ~/.task
git clone git@git.the-hawk.us:misc/cfg/taskrc.git ~/.task/taskrc
ln -s ~/.task/taskrc/taskrc ~/.taskrc

# i3
mkdir -p ~/.config/i3
git clone git@git.the-hawk.us:misc/cfg/i3rc.git ~/.config/i3/i3rc
ln -s ~/.config/i3/i3rc/config ~/.config/i3/config

# timetrap
mkdir -p ~/.timetrap
git clone git@git.the-hawk.us:misc/cfg/timetrap.git ~/.timetrap/formatters
ln -s ~/Dropbox/databases/timetrap.db ~/.timetrap.db

# Setup update crontab for server users
uname -r | grep fc
if [[ $? != 0 ]]
then
    crontab -l > tempcron
    echo "* 00 * * * ~/bin/update" >> tempcron
    crontab tempcron
    rm tempcron
fi
