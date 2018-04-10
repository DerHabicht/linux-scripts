#!/bin/bash

if [[ $1 < 6 ]] && [[ $1 > 0 ]]
then
    echo "FAL $1" > $HOME/.thus
    cat "$HOME/.thus"
fi
