#!/bin/bash

echo "Before continuing:"
echo "  - Install RPMForge"
echo "  - Run updates"
echo "  - Make sure SSH keys have been added to Lazarus and GitHub"
echo "  - Have your GPG keyring imported"
echo "  - Install Dropbox"
echo "  - Have the id for your signing key ready (gpg2 --list-secret-keys --keyid-format LONG)"
echo "Are you ready to continue?"
read goon
if [[ "$goon" != "yes" ]]
then
    exit
fi

cd $HOME

# Basic setups
# Git
echo "Git signing key: "
read key
sudo dnf install git
git config --global gpg.program gpg2
git config --global user.name "Robert Herschel Hawk"
git config --global user.email "robert@the-hawk.us"
git config --global user.signingkey $key

# THUS Utils
echo "Setting up THUS utliities..."
mkdir $HOME/bin
ln -s $HOME/lib/thus-utils/active.sh $HOME/bin/active
ln -s $HOME/lib/thus-utils/fal.sh $HOME/bin/fal
ln -s $HOME/lib/thus-utils/off.sh $HOME/bin/off
ln -s $HOME/lib/thus-utils/pim.sh $HOME/bin/pim
ln -s $HOME/lib/thus-utils/publish.sh $HOME/bin/publish
ln -s $HOME/lib/push.sh $HOME/bin/push
ln -s $HOME/lib/register.sh $HOME/bin/register
ln -s $HOME/lib/start_gollum.sh $HOME/bin/start_gollum
ln -s $HOME/lib/update.sh $HOME/bin/update
ln -s $HOME/lib/update_nano.sh $HOME/bin/update_nano

# bash_profile and bashrc
echo "Setting up bash profile..."
mkdir $HOME/.config/
git clone git@git.the-hawk.us:misc/cfg/termrc.git $HOME/.config/termrc
ln -s $HOME/.config/termrc/bash_profile $HOME/.bash_profile
ln -s $HOME/.config/termrc/bashrc $HOME/.bashrc

# vimrc
echo "Setting up Vim..."
sudo dnf install vim gvim
git clone@github.com:DerHabicht/vim.git $HOME/.vim
$HOME/.vim/install.sh
git config --global core.editor vim

uname -r | grep fc
if [[ $? == 0 ]]
then
    # Install Spacemacs
    sudo dnf install emacs
    rm -rf emacs.d
    rm -rf .emacs
    git clone git@git.the-hawk.us:misc/spacemacs.git $HOME/.emacs.d

    # Blog, wiki, and PIM links
    git clone git@git.the-hawk.us:www/home/sundry-musings.com.git
    ln -s $HOME/devel/www/sundry-musings.com $HOME/blog
    git clone git@git.the-hawk.us:misc/wiki.git
    git clone git@git.the-hawk.us:misc/org.git

    # Install dekstop-only utilities
    echo "Setting up status file..."
    echo "FALCON 1" > $HOME/.thus

    # taskrc
    echo "Setting up TaskWarrior..."
    sudo dnf install taskwarrior
    mkdir $HOME/.task
    git clone git@git.the-hawk.us:misc/cfg/taskrc.git $HOME/.task/taskrc
    ln -s $HOME/.task/taskrc/taskrc $HOME/.taskrc
    task sync

    # i3
    echo "Setting up i3"
    sudo dnf install i3 i3status dmenu i3lock feh conky
    mkdir -p $HOME/.config/i3
    git clone git@git.the-hawk.us:misc/cfg/i3rc.git $HOME/.config/i3/i3rc
    ln -s $HOME/.config/i3/i3rc/config $HOME/.config/i3/config
    mkdir -p $HOME/.config/i3status
    ln -s $HOME/.config/i3/i3rc/i3status.conf $HOME/.config/i3status/config

    # timetrap
    echo "Setting up timetrap..."
    sudo dnf install ruby ruby-devel sqlite sqlite-devel
    gem install timetrap
    mkdir -p $HOME/.timetrap
    git clone git@git.the-hawk.us:misc/cfg/timetrap.git $HOME/.timetrap/formatters
    ln -s $HOME/Dropbox/databases/timetrap.db $HOME/.timetrap.db

    # TWInput
    echo "Setting up TWInput..."
    git clone git@github.com:DerHabicht/twinput.git $HOME/lib/twinput
    ln -s $HOME/lib/twinput/twinput.py $HOME/bin/twinput

    # MakeDoc
    echo "Setting up MakeDoc..."
    git clone git@github.com:DerHabicht/makedoc.git $HOME/lib/makedoc

    # Minecraft
    echo "Setting up Minecraft..."
    wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u162-b12/0da788060d494f5095bf8624735fa2f1/jdk-8u162-linux-x64.rpm
    sudo rpm -ivh $HOME/Downloads/jdk-8u162-linux-x64.rpm
    sudo alternatives --config java
    wget -O $HOME/lib/Minecraft.jar http://s3.amazonaws.com/Minecraft.Download/launcher/Minecraft.jar
    echo "Running the Minecraft launcher to init the .minecraft directory..."
    java -jar $HOME/lib/Minecraft.jar
    git clone git@github.com:DerHabicht/minecraft-utils.git $HOME/lib/minecraft-utils
    ln -s $HOME/lib/minecraft-utils/client.sh $HOME/bin/mc

    # MRs
    git clone git@git.the-hawk.us:docs/home/SOP.git $HOME/Documents/home/SOP
    git clone git@git.the-hawk.us:prog/home/mrman.git $HOME/lib/mrman
    ln -s $HOME/lib/mrman/mrman.py $HOME/bin/mrman

    # Set up TeXLive
    mkdir $HOME/temp/
    cd $HOME/temp/
    wget -O - http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz | tar xzf -
    sudo install-tl*/install-tl
    git clone git@git.the-hawk.us:misc/texmf.git $HOME/texmf
    texhash $HOME/texmf

else
    # Setup update crontab for server users
    crontab -l > tempcron
    echo "* 00 * * * $HOME/bin/update" >> tempcron
    crontab tempcron
    rm tempcron
fi
