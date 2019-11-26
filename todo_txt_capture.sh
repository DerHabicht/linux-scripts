#/bin/bash

if [[ "$1" ]]
then
    td add "@inbox $@"
else
    echo "Please specify a task to capture."
fi

