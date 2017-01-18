#!/bin/bash

tasksheet=`cat ~/.tasksheet`
if [ "$?" == 0 ]
then
    timetrap out $tasksheet
    task uuid:`timetrap display --format current_clock $tasksheet` done
    rm ~/.tasksheet
    timetrap display $tasksheet
else
    echo "No registered task clock."
fi
