#!/bin/bash

gzip -d $1
cat "${1%.*}" | less
gzip "${1%.*}"
