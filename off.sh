#!/bin/bash

source "$HOME/lib/thus-utils/default_repos.sh"

if [ "$1" == "-r" ]
then
    echo "Are you sure you want to restart $HOSTNAME? (yes/no): "
elif [ "$1" == "-d" ]
then
    echo "Simulate shutdown for $HOSTNAME? (yes/no): "
else
    echo "Are you sure you want to shutdown $HOSTNAME? (yes/no): "
fi

if [ "$1" != "-y" ]
then
    read response

    if [ "$response" != "yes" ]
    then
        exit
    fi
fi

# Deactivate projects
$HOME/lib/thus-utils/active.sh done

# Sync Taskwarrior
task context none
task sync

echo "Here"

# Update NaNoWriMo wordcount
update_nano

# Sync relevant Git repositories
cat ~/.proj_active >> ~/.proj_modified
printf "%s\n" "${default_repos[@]}" >> ~/.proj_modified

failed=()
while IFS= read -r line
do
    cd "$line"
    printf "\nCommitting `pwd`...\n"
    git add *
    git commit -a -m "Automated commit from $HOSTNAME"
    git push
    if [ "$?" != 0 ]
    then
        failed+=(`pwd`)
    fi
done < ~/.proj_modified

rm ~/.proj_modified

if [ ${#failed[@]} == 1 ]
then
    printf "\n$(tput setaf 1)1 repository failed to push:\n"
    printf '    %s\n' "${failed[@]}"
    echo "$(tput sgr0)"

    if [ "$1" != "-y" ]
    then
        echo "Do you want to continue? (yes/no):"
        read response
        if [ "$response" != "yes" ]
        then
            exit
        fi
    fi
elif [ ${#failed[@]} -gt 1 ]
then
    printf "\n$(tput setaf 1)${#failed[@]} repositories failed to push:\n"
    printf '    %s\n' "${failed[@]}"
    echo "$(tput sgr0)"
    if [ "$1" != "-y" ]
    then
        echo "Do you want to continue? (yes/no):"
        read response
        if [ "$response" != "yes" ]
        then
            exit
        fi
    fi
fi

if [ "$1" == "-r" ]
then
    reboot
elif [ "$1" == "-d" ]
then
    exit
else
    poweroff
fi
