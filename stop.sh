#!/bin/bash

# Remember current stderr handler, then set stderr to /dev/null
exec 3>&2
exec 2> /dev/null

clear

tasksheet=`cat ~/.tasksheet`
if [ "$?" == 0 ]
then
    timetrap out $tasksheet
    task uuid:`timetrap display --format current_clock $tasksheet` stop
    rm ~/.tasksheet
    timetrap display $tasksheet
else
    echo "No registered task clock."
fi

active

# Restore the stderr handler
exec 2>&3
