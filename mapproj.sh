#!/bin/bash

regex="\w+\.(\w+)\.?.*"

if [[ ! "$1" ]]
then
    jq . $HOME/.proj_map.json
elif [[ "$1" =~ $regex ]]
then
    dir=`jq .${BASH_REMATCH[1]} $HOME/.proj_map.json`
    if [[ "$dir" == "null" ]]
    then
        exit 1
    fi
elif [[ "$1" == "add" ]]
then
    jq ". + {$2: \"$3\"}" $HOME/.proj_map.json > $HOME/.proj_map.json
else
    exit 1
fi
