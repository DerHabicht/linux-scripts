#!/bin/bash

journal_path=$HOME/journal/`date +'%Y'`/`date +'%B'`/`date +'%Y-%m-%d'`.md

if [ -a $journal_path ]
then
    gvim $journal_path
else
    printf "%s\ndate: %s\n...\n\n" "---" `date +"%Y-%m-%d"` > $journal_path
    gvim $journal_path +X
fi
