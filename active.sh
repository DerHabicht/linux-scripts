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
    thisproj=`cat ~/.taskproj`
    if [ "$?" == 0 ]
    then
        rm ~/.taskproj
        echo "Project $thisproj is now inactive."
    else
        echo "No active project."
    fi
elif [ "$1" ]
then
    echo $1 > ~/.taskproj
    echo "Activated project $1."
    task project:$1
else
    thisproj=`cat ~/.taskproj`
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
