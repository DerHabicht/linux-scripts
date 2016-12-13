gzip -d $1
cat "${1%.*}" | vim -c 'set ft=man ts=8 nomod nolist nonu noma' -
gzip "${1%.*}"
