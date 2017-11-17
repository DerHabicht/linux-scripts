#!/bin/bash

clear

if [ "$1" ]
then
    sheet=`task _get rc.context`
    if [ "$sheet" ]
    then
        timetrap sheet $sheet
        timetrap in `task "$1" uuids`
        if [ "$?" == 0 ]
        then
            task "$1" start
        fi
        export noclear=1
        active
    else
        echo "Set context before starting task."
    fi
else
    active
fi
