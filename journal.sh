#!/bin/bash

journal_path=$HOME/journal/`date +'%Y'`/`date +'%B'`
journal_file=$journal_path/`date +'%Y-%m-%d'`.md

if [ ! -d "$journal_path" ]
then
    mkdir -p $journal_path
fi

if [ -a $journal_file ]
then
    gvim $journal_file
else
    printf "%s\ndate_: %s\ntlp_: RED\n...\n\n" "---" `date +"%Y-%m-%d"` \
        > $journal_file
    gvim $journal_file +X
fi
