#!/bin/bash

clear

if [ "$1" ] && [ "$2" ]
then
    timetrap sheet "$2"
    timetrap in `task "$1" uuids`
    if [ "$?" == 0 ]
    then
        task "$1" start
        timetrap display
        echo "$2" > ~/.tasksheet
    fi
else
    active
fi
