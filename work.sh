#!/bin/bash

timetrap sheet work_schedule
timetrap in
if [ "$?" != 0 ]
then
    timetrap out
fi
timetrap display
