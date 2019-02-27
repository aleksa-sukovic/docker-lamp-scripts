#!/bin/bash

# Output colors
red='\e[1;31m%s\e[0m\n'
green='\e[1;32m%s\e[0m\n'
blue='\e[1;34m%s\e[0m\n'

# Reading arguments
while [ "$1" != "" ]
do
    case $1 in
        -o|--output)
        shift
        OUTPUT_FILE=$1
        shift
        ;;
        -p|--project)
        shift
        PROJECT=$1                      # name of project folder (e.g. project_1)
        PROJECT_PARENT_DIR="/var/www"   # assuming project is located at root
        shift
        ;;
    esac
done

# If project is not provided, using current folder as project
if [[ -z $PROJECT ]]; then
    PROJECT_PARENT_DIR=$(dirname $(pwd)) # parent folder path (e.g. /var/www)
    PROJECT=${PWD##*/}                   # current folder name (e.g. project_1)
fi

# Checking if setup folder and configuration file is present
printf "$blue" "Checking project: '$PROJECT'\n"
SETUP_FOLDER="${PROJECT_PARENT_DIR}/${PROJECT}/setup"

if [[ ! -d $SETUP_FOLDER ]] || [[ ! -f $SETUP_FOLDER/setup.conf ]]; then
    printf "$red" "This script requires 'setup' folder with 'setup.conf' file! Skipping '$PROJECT' project..."
    exit 1
fi

# Loading setup.conf
printf "Project '$PROJECT' contains 'setup.conf' file, proceding with configuration...\n"
. $SETUP_FOLDER'/setup.conf'

# Generating SSL certificate if neccesary
if [[ $SETUP_SSL -eq 1 ]]; then
    CMD="/scripts/setup-ssl.sh --domain $SETUP_DOMAIN --working-dir $SETUP_FOLDER"
    eval "$CMD"

    result=$?

    if [[ $result -eq 0 ]] && [[ $SETUP_ENVIRONMENT = 'darwin' ]]; then
        MESSAGE=" sudo security add-trusted-cert -d -r trustAsRoot -p ssl -k /Library/Keychains/System.keychain ${PROJECT}/setup/$SETUP_DOMAIN.crt"
    elif [[ $result -eq 0 ]]; then
        MESSAGE="sudo cp ${PROJECT}/setup/$SETUP_DOMAIN.crt /etc/ca-certificates/trust-source/anchors/"
    fi

    if [[ $result -eq 0 ]] && [[ ! -z $OUTPUT_FILE ]]; then
        echo $MESSAGE >> "$OUTPUT_FILE"
    elif [[ $result -eq 0 ]]; then
        printf "$green" "$MESSAGE";
    fi
fi

# Creating Virtual Host
CMD="/scripts/setup-vhost.sh --domain $SETUP_DOMAIN --document-root /var/www/$SETUP_DOCUMENT_ROOT --entrypoint $SETUP_ENTRYPOINT"
if [[ $SETUP_SSL -eq 0 ]]; then
    CMD="$CMD --no-ssl"
fi
eval "$CMD"

printf "$blue" "Configuration for project '$PROJECT' is complete!\n\n"
