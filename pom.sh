#!/bin/bash
# Remember current stderr handler, then set stderr to /dev/null
exec 3>&2
exec 2> /dev/null

regex="Pomodoro Count +([0-9]+)"

text=`task $1`
if [[ $text =~ $regex ]]
then
    task $1 modify pom:$((${BASH_REMATCH[1]} + 1))
fi

# Restore the stderr handler
exec 2>&3
