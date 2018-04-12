#!/bin/bash

# Constants
#   - seconds: the entire length of the timer in seconds (1500s = 25min)
#   - tick: play a 'tick' sound at this interval (in seconds)
timeout=5
count=1

# Empty the screen
clear

# Remember current stderr handler, then set stderr to /dev/null
exec 3>&2
exec 2> /dev/null

# Shut off the cursor blink
tput civis

# Play start sound
mplayer -msglevel all=0 ~/lib/thus-utils/beeps/computerbeep_9.mp3

# Catch Ctl-C so we can gracefully exit the loop
trap 'interrupted=1;break' INT

# Execute timer loop.
ret_val=1
while [ "$ret_val" != 0 ]
do
    clear
    echo "Attempting to ping $1...                 "
    mplayer -msglevel all=0 ~/lib/thus-utils/beeps/computerbeep_4.mp3
    ping -c 1 -W 5 "$1" > /dev/null
    ret_val=$?
done


if [ "$interrupted" != 1 ]
then
    while [ 1 == 1 ]
    do
        clear
        echo "Connection detected!"
        mplayer -msglevel all=0 ~/lib/thus-utils/beeps/alert04.mp3
        sleep 1
    done
else
    echo "Listening interrupted."
fi

# Clear the screen
clear

# Reset the default Ctl-C handler
trap - INT

# Restore the stderr handler
exec 2>&3

# Turn cursor blink back on
tput cnorm
