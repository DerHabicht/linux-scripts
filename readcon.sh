#!/bin/bash

if [[ $1 < 6 ]] && [[ $1 > 0 ]]
then
    echo "READCON $1" > $HOME/.readcon
    cat "$HOME/.readcon
fi
