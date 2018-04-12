#!/bin/bash

# Differences between this script and pom.sh:
#   pom.sh actually starts a timer and will kill itself after 25 minutes
#   pom.sh "ticks" every 30 seconds
#   ptrack.sh does not play a tick
#   ptrack.sh will not kill itself, you have to kill it
#
# Otherwise the functionality is the same. It starts a clock in timetrap, will
# listen to and record interruption marks, and stop the clock when the process
# dies. The intention is to use this in conjunction with an external timer
# (such as a kitchen timer) instead of having the computer do the timing, but
# still have all of the interruption stuff tracked in timetrap.

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
start=`$date +%s`
timetrap in
mplayer -msglevel all=0 ~/lib/thus-utils/beeps/computerbeep_9.mp3

# Catch Ctl-C so we can gracefully exit the loop
trap 'break' INT

# Execute timer loop.
while true
do
    # Draw the time remaining.
    # The extra spaces at the end are to ensure that any characters
    # accidentally thrown to the terminal will be overwritten on the next tick.
    echo -ne "Pomodoro ($interruption): $(date --date @$((`date +%s` - $start)) +%H:%M:%S)             \r"

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
done

# Reset the default Ctl-C handler
trap - INT

# Clear the screen
clear

# Make sure we're on the pom time sheet and clock out.
timetrap sheet pom
timetrap out

# Play finish sound indicating that we've clocked out.
mplayer -msglevel all=0 ~/lib/thus-utils/beeps/alert04.mp3

# Restore the stderr handler
exec 2>&3

# Turn cursor blink back on
tput cnorm

# Show the pom timesheet
timetrap display
