#!/bin/bash

# Remember current stderr handler, then set stderr to /dev/null
exec 3>&2
exec 2> /dev/null

rdir=$(basename $2)

cd $2

if [ $? != 0 ]
then
    exit
fi

# Initialize origin
git remote | grep "origin" > /dev/null
if [ $? != 0 ]
then
    echo "Configuring origin..."
    git remote add origin "git@git.the-hawk.us:$1/$rdir.git" > /dev/null

    git fetch > /dev/null
    if [ $? != 0 ]
    then
        echo "Uploading bare repo to origin..."
        cd ..
        git clone --bare $2 > /dev/null
        scp -r "$2.git" "git@git.the-hawk.us:$1/" > /dev/null
        rm -rf "$2.git"
        cd $2
        git fetch > /dev/null
        if [ $? == 0 ]
        then
            printf "$(tput setaf 2)"
            echo "Successfully added bare repo to origin."
            printf "$(tput sgr0)"
            git branch -u origin/master master
        else
            printf "$(tput setaf 1)Failed to add bare repo to origin."
            printf "$(tput sgr0)"
        fi
    fi
    printf "$(tput setaf 2)"
    echo "Origin configured."
    printf "$(tput sgr0)"
else
    printf "$(tput setaf 2)"
    echo "Origin already configured."
    printf "$(tput sgr0)"
fi

# Initialize submit
if [ "$3" == "submit" ]
then
    git remote | grep "submit" > /dev/null
    if [ $? != 0 ]
    then
        echo "Configuring submit..."
        source $HOME/.ssh/byuill.sh
        if [ $? == "0" ]
        then
            submit_repo="ssh://thehawk@byuill:215/~/repos/$rdir.git"
            git remote add submit $submit_repo > /dev/null

            gitp fetch submit > /dev/null
            if [ $? != 0 ]
            then
                echo "Uploading bare repo to submit..."
                cd ..
                git clone --bare $2 > /dev/null
                scpp -r -P 215 "$2.git" "thehawk@byuill:repos/" > /dev/null
                rm -rf "$2.git"
                cd $2
                gitp fetch submit > /dev/null
                git fetch > /dev/null
                if [ $? == 0 ]
                then
                    printf "$(tput setaf 2)"
                    echo "Successfully added bare repo to submit."
                    printf "$(tput sgr0)"
                else
                    printf "$(tput setaf 1)Failed to add bare repo to submit."
                    printf "$(tput sgr0)"
                fi
            fi
            printf "$(tput setaf 2)"
            echo "Submit configured."
            printf "$(tput sgr0)"
        else
            printf "$(tput setaf 1)"
            echo "Unable to source password file."
            printf "$(tput sgr0)"
        fi
    else
        printf "$(tput setaf 2)"
        echo "Submit already configured."
        printf "$(tput sgr0)"
    fi
fi

# Restore the stderr handler
exec 2>&3
