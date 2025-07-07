#!/bin/bash

# This script builds the project
set -e

# check if local.properties exists
# if it exists source it
if [ -f local.properties ]; then
    echo "Sourcing local.properties"
    source local.properties
else
    echo "local.properties not found, using default values"

fi

# run docker compose as specified in README.md
# append any arguments passed to this script
if [ -z "$1" ]; then
    echo "No arguments provided, running docker compose up"
    docker compose up --build
else
    echo "Running docker compose up with arguments: $@"
    docker compose up --build "$@"
fi
