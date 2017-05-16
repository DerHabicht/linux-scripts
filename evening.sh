#!/bin/bash


time=30

while [ $time -gt 0 ]
do
    if [ $time == 1 ]
    then
        text="System will shut down in $time minute.\nTo override, kill $$."
    else
        text="System will shut down in $time minutes.\nTo override, kill $$."
    fi


    if [ $time == 30 ] || [ $time == 15 ] || [ $time == 5 ] || [ $time == 1 ]
    then
        zenity --info --title="Shutdown" --text="$text" &
    fi
    echo $((time-=1)) > /dev/null
    sleep 60
done

$HOME/lib/thus_utils/off -y
