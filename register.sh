add_to_list() {
    git status > /dev/null
    if [ "$?" == 0 ]
    then
        grep "`pwd`" "$1" > /dev/null
        if [ "$?" == 1 ]
        then
            pwd >> "$1"
        fi
        return 0
    else
        echo "`pwd` is not a Git repository."
        return 1
    fi
}

remove_from_list() {
    sed -i "s:`pwd`::g" "$1"
    success="$?"
    sed -i "/^$/d" "$1"

    return $success
}


# Remember current stderr handler, then set stderr to /dev/null
exec 3>&2
exec 2> /dev/null

if [ "$1" == "-s" ]
then
    echo "[ Active Projects ]"
    cat ~/.proj_active
    echo ""
    echo "[ Modified Projects ]"
    cat ~/.proj_modified
elif [ "$1" == "-i" ]
then
    remove_from_list "$HOME/.proj_active"
    if [ "$?" == 0 ]
    then
        echo "`pwd` has been removed from the active projects file."
    else
        echo "`pwd` could not be removed from the active projects file."
    fi
elif [ "$1" == "-u" ]
then
    remove_from_list "$HOME/.proj_modified"
    if [ "$?" == 0 ]
    then
        echo "`pwd` has been removed from the modified projects file."
    else
        echo "`pwd` could not be removed from the modified projects file."
    fi
elif [ "$1" == "-a" ]
then
    add_to_list "$HOME/.proj_active"
    if [ "$?" == 0 ]
    then
        echo "`pwd` has been added to the active projects file."
    else
        echo "`pwd` could not be added to the active projects file."
    fi
elif [ "$1" == "-r" ]
then
    add_to_list "$HOME/.proj_modified"
    if [ "$?" == 0 ]
    then
        echo "`pwd` has been added to the modified projects file."
    else
        echo "`pwd` could not be added to the modified projects file."
    fi
elif [ "$1" == "-n" ]
then
    echo "nop" > /dev/null
else
    echo "-r                  Mark repository as modified"
    echo "-a                  Mark repository as active"
    echo "-u                  Remove repo from modified list"
    echo "-i                  Remove repo from active list"
    echo "-s                  Print the active and modified repo list"
fi

# Restore the stderr handler
exec 2>&3
