#!/bin/bash

if [ "$1" ]
then
    cd "$1"
fi
buffalo test
