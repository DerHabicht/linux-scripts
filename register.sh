# Remember current stderr handler, then set stderr to /dev/null
exec 3>&2
exec 2> /dev/null

if [ "$1" == "-s" ]
then
    cat ~/.proj_dirs
else
    git status > /dev/null
    if [ "$?" == 0 ]
    then
        pwd >> ~/.proj_dirs
        echo "`pwd` has been added to the modified projects file."
    else
        echo "`pwd` is not a Git repository."
    fi
fi

# Restore the stderr handler
exec 2>&3
