#!/bin/bash

# Remember current stderr handler, then set stderr to /dev/null
exec 3>&2
exec 2> /dev/null

clear
if [ "$1" == "in" ]
then
    task context $2
    if [ "$?" == 0 ]
    then
        timetrap sheet "$2_schedule"
        timetrap in
        timetrap display "$2_schedule"
    else
        "Context $2 does not exist."
    fi
elif [ "$1" == "out" ]
then
    context=`task _get rc.context`

    if [ "$context" ]
    then
        task context none
        timetrap sheet $context"_schedule"
        timetrap out
        timetrap display $context"_schedule"
    else
        echo "No context currently set."
    fi
else
    context=`task _get rc.context`

    if [ "$context" ]
    then
        timetrap display "$context\_schedule"
    else
        echo "No context currently set."
    fi
fi

# Restore the stderr handler
exec 2>&3
