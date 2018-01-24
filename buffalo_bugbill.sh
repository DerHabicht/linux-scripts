#!/bin/bash

if [ "$2" ]
then
    cd "$2"
fi
buffalo bill -t -gcflags="-N -l"
dlv --listen=:2345 --headless=true --api-version=2 exec ./bin/$1
