#!/bin/bash

setxkbmap -query | grep 'us(intl)' > /dev/null
if [ "$?" == 1 ]
then
    setxkbmap -layout 'us(intl)'
else
    setxkbmap -layout 'us'
fi

setxkbmap -query | grep 'layout'
