#!/bin/bash

# Remember current stderr handler, then set stderr to /dev/null
exec 3>&2
exec 2> /dev/null

clear

context=`task _get rc.context`
if [ "$?" == 0 ]
then
    timetrap out $context
    task uuid:`timetrap display --format current_clock $context` done
else
    echo "No context set."
fi

export noclear=1
active

# Restore the stderr handler
exec 2>&3
