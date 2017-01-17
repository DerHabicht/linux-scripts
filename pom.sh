#!/bin/bash

# Constants
#   - seconds: the entire length of the timer in seconds (1500s = 25min)
#   - tick: play a 'tick' sound at this interval (in seconds)
seconds=1500
tick=30

# Empty the screen
clear

# Remember current stderr handler, then set stderr to /dev/null
exec 3>&2
exec 2> /dev/null

# Shut off the cursor blink
tput civis

# Set time sheet and kill any running Pomodoros
timetrap sheet pom
timetrap out

# Start the clock and play a startup sound
end=$((`date +%s` + $seconds))
next_tick=$((`date +%s` + $tick))
timetrap in
mplayer -msglevel all=0 ~/lib/thus_utils/beeps/computerbeep_9.mp3

# Catch Ctl-C so we can gracefully exit the loop
trap 'break' INT

# Execute timer loop.
while [ "$end" -ge `date +%s` ]
do
    # Draw the time remaining.
    # The extra spaces at the end are to ensure that any characters
    # accidentally thrown to the terminal will be overwritten on the next tick.
    echo -ne "Pomodoro ($interruption): $(date -u --date @$(($end - `date +%s` )) +%H:%M:%S)             \r"

    read -s -t 0.1 -N 1 key
    if [ "$key" == "i" ]
    then
        interruption="$interruption'"
        timetrap sheet pom
        timetrap edit "$interruption" > /dev/null
    elif [ "$key" = "e" ]
    then
        interruption="$interruption-"
        timetrap sheet pom
        timetrap edit "$interruption" > /dev/null
    fi

    # Play the 'tick' sound
    if [ "$next_tick" -le `date +%s` ]
    then
        mplayer -msglevel all=0 ~/lib/thus_utils/beeps/computerbeep_4.mp3
        next_tick=$((`date +%s` + $tick))
    fi
done

# Reset the default Ctl-C handler
trap - INT

# Clear the screen
clear

# Make sure we're on the pom time sheet and clock out.
timetrap sheet pom
timetrap out

# Play finish sound indicating that we've clocked out.
mplayer -msglevel all=0 ~/lib/thus_utils/beeps/alert04.mp3

# Restore the stderr handler
exec 2>&3

# Turn cursor blink back on
tput cnorm

# Show the pom timesheet
timetrap display
