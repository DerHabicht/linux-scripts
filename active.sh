#!/bin/bash

# Remember current stderr handler, then set stderr to /dev/null
exec 3>&2
exec 2> /dev/null

if [ ! "$noclear" ]
then
    clear
fi

if [ "$1" == "done" ]
then
    thisproj=`cat $HOME/.proj_task`
    if [ "$?" == 0 ]
    then
        rm $HOME/.proj_task
        echo "Project $thisproj is now inactive."
    else
        echo "No active project."
    fi
elif [ "$1" ]
then
    echo $1 > $HOME/.proj_task

    if [ -d "$HOME/$1" ]
    then
        cd "$1"
        git status
        if [ "$?" == 0 ]
        then
            $HOME/lib/thus-utils/register.sh -r
        fi
    fi

    echo "Activated project $1."
    task project:$1
else
    thisproj=`cat $HOME/.proj_task`
    if [ "$?" == 0 ]
    then
        task project:$thisproj
    else
        echo "No active project."
    fi
fi

noclear=0

# Restore the stderr handler
exec 2>&3
