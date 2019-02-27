#!/bin/bash

# Output colors
red='\e[1;31m%s\e[0m\n'
green='\e[1;32m%s\e[0m\n'
blue='\e[1;34m%s\e[0m\n'
magenta='\e[1;35m%s\e[0m\n'

# Parsing arguments
if [[ $# -eq 0 ]]; then
    printf "$red" "Please provide path to projects you wish to initialize"
    exit 1
fi

WWW_FOLDER=${1%/*}

# Welcome messages
printf "$blue" "This is initialization script which will create neccesary project configuration in Apache"

printf "$magenta" "Are you running this initialization script on Linux or Mac? [linux, darwin] "

read ENVIRONMENT

printf "Searching for valid projects...\n"

# Creating empty post-setup script to be executed in host machine
if [[ -f "$WWW_FOLDER/post_setup.sh" ]]; then
    rm -f "$WWW_FOLDER/post_setup.sh"
fi

touch "$WWW_FOLDER/post_setup.sh"

cd $WWW_FOLDER
for PROJECT in */ ; do
    PROJECT=${PROJECT%/} # removing trailing slash

    COMMAND="/scripts/setup-project.sh --output $WWW_FOLDER/post_setup.sh --project $PROJECT --environment $ENVIRONMENT"

    eval $COMMAND
done

# Post setup message
printf "$blue" "Configuration for all found projects is now done! Don't forget to do the following:"
printf "$green" "1) Add neccessary hosts in your /etc/hosts file. Host names can be found in 'setup.conf' file of each project"

# If SSL was used in one of the projects, finishing post-setup script
if [[ -s "$WWW_FOLDER/post_setup.sh" ]]; then
    if [[ $ENVIRONMENT = 'linux' ]]; then
        echo "sudo trust extract-compat" >> "$WWW_FOLDER/post_setup.sh"
    fi

    echo "rm -f ./post_setup.sh" >> "$WWW_FOLDER/post_setup.sh"

    printf "$green" "2) Go to your mounted www folder and execute:"
    printf "$green" "'sh ./post_setup.sh'"
else
    rm -f "$WWW_FOLDER/post_setup.sh"
fi
