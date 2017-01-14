add_to_list() {
    git status > /dev/null
    if [ "$?" == 0 ]
    then
        pwd >> "$1"
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

if [ "$1" == "--show-modified" ]
then
    cat ~/.proj_dirs
elif [ "$1" == "--show-active" ]
then
    cat ~/.active_proj_dirs
elif [ "$1" == "--mark-inactive" ]
then
    remove_from_list "$HOME/.active_proj_dirs"
    if [ "$?" == 0 ]
    then
        echo "`pwd` has been removed from the active projects file."
    else
        echo "`pwd` could not be removed from the active projects file."
    fi
elif [ "$1" == "--mark-unmodified" ]
then
    remove_from_list "$HOME/.proj_dirs"
    if [ "$?" == 0 ]
    then
        echo "`pwd` has been removed from the modified projects file."
    else
        echo "`pwd` could not be removed from the modified projects file."
    fi
elif [ "$1" == "-a" ]
then
    add_to_list "$HOME/.active_proj_dirs"
    if [ "$?" == 0 ]
    then
        echo "`pwd` has been added to the active projects file."
    else
        echo "`pwd` could not be added to the active projects file."
    fi
elif [ "$1" == "-r" ]
then
    add_to_list "$HOME/.proj_dirs"
    if [ "$?" == 0 ]
    then
        echo "`pwd` has been added to the modified projects file."
    else
        echo "`pwd` could not be added to the modified projects file."
    fi
else
    echo "-r                  Mark repository as modified"
    echo "-a                  Mark repository as active"
    echo "--mark-unmodified   Remove repo from modified list"
    echo "--mark-inactive     Remove repo from active list"
    echo "--show-modified     Print the modified repo list"
    echo "--show-active       Print the active repo list"
fi

# Restore the stderr handler
exec 2>&3
