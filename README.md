# Docker LAMP Project Scripts

Scripts for initializing projects in Docker LAMP stack setup

## Prerequisite

- Docker
- Docker LAMP Lumen (...)

## Information

Main purpose of these scripts is to initialize projects so that they are accessible to Apache server

Here is the listing of all scripts, their requirements and actual functions
 - All scripts should be run from inside of the Apache Docker container

## Projects

As these scripts are meant to initialize projects, we now must define a valid project

Valid project is a project represented by a folder with following specifications

- Folder must contain `setup` folder
- Folder `setup` must contain file `setup.conf` which represents parameters specific to that project
- File `setup.conf` must contain following variables
    1. *SETUP_DOMAIN*        - represents domain bound to this project
    2. *SETUP_DOCUMENT_ROOT* - folder from which Apache is serving this project
    4. *SETUP_ENTRYPOINT*    - name of entry file which is served by Apache
    5. *SETUP_SSL*           - indicates if SSL should be configured (values = [0, 1])

### Setup

Script which initializes multiple projects found in folder you specify as argument

- FileName : `setup.sh`
- Run location : anywhere
- Function : Initializes every project found in given folder
  - For each valid project, separate script (`setup-project.sh`) is run which does the actual initialization

### Setup Project

Initializes given project. This means setting up the Apache virtual host, SSL certificate and issuing appropriate instructions to be done on the host machine

- FileName : `setup-project.sh`
- Run location : anywhere | project folder
- Function : Initializes given project using its `setup.conf` configuration file
  - If parameter `--project` is passed then that location is used as project to be configured, else current folder is used as project
  - If parameter `--output` is passed, every post install instruction that should be executed on host machine will be written to this output file, else those instructions will be printed to terminal
  - If parameter `--environment` is passed, its value is used to determine right post install commands based on your host OS. You can pass either `linux` or `darwin`. Default value is `linux`
- Params :
  - `--project` : Folder representing project we want to initialize
  - `--output` : *[optional]* Name of the output file in which we write instruction to be executed on host machine, if omitted, those instructions are printed to terminal
  - `--environment` : *[optional]* Type of your host OS. Determines the format of post install script.

### Setup SSL

Sets up self-signed SSL certificates for given domain

- FileName : `setup-ssl.sh`
- Run location : anywhere
- Function : Generates valid self-signed certificates for given domain, and places them to /etc/ssl/certs folder
- Params :
  - `--domain` : name of the domain for which certificate should be issued
  - `--working-dir` : name of directory in which this script should create its temporary files
    - Not that these files will be automatically removed after the script finishes

### Setup Virtual Host

Creates and enables virtual host for given input variables

- FileName : `setup-vhost.sh`
- Run location : anywhere
- Function : Creates new Apache virtual host configuration based on input parameters
  - If SSL is used, then certificates that were created by SetupSSL script are used (they are saved in /etc/ssl/certs folder as you may recall)
- Params :
  - `--no-ssl` : indicates that SSL should not be setup.
  - `--domain` : name of the virtual host domain (if using SSL, domain should be same as the one used when generating certificates)
  - `--document-root` : folder from which Apache is serving this site
  - `--entrypoint` : name of the file to be loaded on `/` request