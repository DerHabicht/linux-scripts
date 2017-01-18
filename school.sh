#!/bin/bash

timetrap sheet school_schedule
timetrap in
if [ "$?" != 0 ]
then
    timetrap out
fi
timetrap display
