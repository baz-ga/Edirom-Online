#!/bin/bash

# This script builds the project
set -e

# ask user if he wants to make sure volumes from previous build and docker compose runs are deleted
    read -p "Do you want to delete volumes from previous build and docker compose runs? (y/n): " delete_volumes
    if [ "$delete_volumes" == "y" ]; then
        echo "Deleting volumes..."
        if [ -f local.properties ]; then
            source local.properties
        fi
        docker compose up -d
        docker compose down --volumes --remove-orphans
    fi

# check if local.properties exists
if [ -f local.properties ]; then
    # warn about existing local.properties
    echo "Warning: local.properties already exists with the following properties:"
    cat local.properties

    # ask user if they want to overwrite it
    read -p "Do you want to overwrite the existing local.properties file? (y/n): " overwrite_local_properties
    if [ "$overwrite_local_properties" == "y" ]; then
        echo "Deleting existing local.properties file..."
        rm local.properties

    else
        echo "Continuing with existing local.properties file."
    fi
fi

# check if local.properties exists
# if doesn not exists source it
if [ ! -f local.properties ]; then
    # echo a message if it does not exist
    echo "local.properties not found."
    # ask user if they want to create it
    read -p "Do you want to create a local.properties file? (y/n): " create_local_properties
    if [ "$create_local_properties" == "y" ]; then
        echo "Creating local.properties file..."
        # interactively ask for values of the variables BE_REPO, BE_BRANCH, FE_REPO, FE_BRANCH
        read -p "Enter the URL for your Edirom-Online-Backend repository (BE_REPO, default: https://github.com/Edirom/Edirom-Online-Backend): "
        BE_REPO=${REPLY:-"https://github.com/Edirom/Edirom-Online-Backend"}
        read -p "Enter the branch for your Edirom-Online-Backend repository (BE_BRANCH, default: main): "
        BE_BRANCH=${REPLY:-"main"}
        read -p "Enter the URL for your Edirom-Online-Frontend repository (FE_REPO, default: https://github.com/Edirom/Edirom-Online-Frontend): "
        FE_REPO=${REPLY:-"https://github.com/Edirom/Edirom-Online-Frontend"}
        read -p "Enter the branch for your Edirom-Online-Frontend repository (FE_BRANCH, default: main): "
        FE_BRANCH=${REPLY:-"main"}
        # ask if the user wants to add an Edition XAR archive (EDITION_XAR) defaulting to https://github.com/Edirom/EditionExample/releases/download/v0.1.1/EditionExample-0.1.1.xar
        read -p "Do you want to add an Edition XAR archive (EDITION_XAR, default: https://github.com/Edirom/EditionExample/releases/download/v0.1.1/EditionExample-0.1.1.xar)? (y/n): " add_edition_xar
        if [ "$add_edition_xar" == "y" ]; then
            read -p "Enter the URL for your Edition XAR archive (EDITION_XAR, default: https://github.com/Edirom/EditionExample/releases/download/v0.1.1/EditionExample-0.1.1.xar): "
            EDITION_XAR=${REPLY:-"https://github.com/Edirom/EditionExample/releases/download/v0.1.1/EditionExample-0.1.1.xar"}
        fi
        cat <<EOF > local.properties
export BE_REPO=$BE_REPO
export BE_BRANCH=$BE_BRANCH
export FE_REPO=$FE_REPO
export FE_BRANCH=$FE_BRANCH
export EDITION_XAR=$EDITION_XAR
EOF
    fi
fi

if [ -f local.properties ]; then
    # source the local.properties file
    source local.properties
else
    echo "local.properties not found. Using default values."
fi

# run docker compose as specified in README.md
# append any arguments passed to this script
if [ -z "$1" ]; then
    echo "No arguments provided, running docker compose up"
    docker compose build --no-cache
    docker compose up --force-recreate --build
else
    echo "Running docker compose up with arguments: $@"
    docker compose build --no-cache
    docker compose up --force-recreate --build "$@"
fi
