#!/bin/bash

timetrap sheet home_schedule
timetrap in
if [ "$?" != 0 ]
then
    timetrap out
fi
timetrap display
