#!/bin/bash

# Output colors
red='\e[1;31m%s\e[0m\n'
green='\e[1;32m%s\e[0m\n'
blue='\e[1;34m%s\e[0m\n'

# Welcome messages
printf "$blue" "This is initialization script which will create neccesary project configuration in Apache"
printf "Searching for valid projects...\n"

# Creating empty post-setup script to be executed in host machine
if [[ -f /var/www/post_setup.sh ]]; then
    rm -f /var/www/post_setup.sh
fi

touch /var/www/post_setup.sh

cd /var/www
for PROJECT in */ ; do
    PROJECT=${PROJECT%/} # removing trailing slash

    COMMAND="/scripts/setup-project.sh --output /var/www/post_setup.sh --project $PROJECT"

    eval $COMMAND
done

# Post setup message
printf "$blue" "Configuration for all found projects is now done! Don't forget to do the following:"
printf "$green" "1) Add neccessary hosts in your /etc/hosts file. Host names can be found in 'setup.conf' file of each project"

# If SSL was used in one of the projects, finishing post-setup script
if [[ -s /var/www/post_setup.sh ]]; then
    if [[ $SETUP_ENVIRONMENT != 'darwin' ]]; then
        echo "sudo trust extract-compat" >> /var/www/post_setup.sh
    fi

    echo "rm -f ./post_setup.sh" >> /var/www/post_setup.sh

    printf "$green" "2) Go to your mounted www folder and execute:"
    printf "$green" "'sh ./post_setup.sh'"
else
    rm -f /var/www/post_setup.sh
fi
