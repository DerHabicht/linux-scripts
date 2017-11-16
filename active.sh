#!/bin/bash

# Remember current stderr handler, then set stderr to /dev/null
exec 3>&2
exec 2> /dev/null

if [ "$1" == "done" ]
then
    rm ~/.taskproj
elif [ "$1" ]
then
    echo $1 > ~/.taskproj
else
    thisproj=`cat ~/.taskproj`
    if [ "$?" == 0 ]
    then
        task project:$thisproj
    else
        echo "No active project."
    fi
fi

# Restore the stderr handler
exec 2>&3
