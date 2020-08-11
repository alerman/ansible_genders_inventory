#!/bin/bash

# ============================================== #
# This script enables developers to learn how to #
# do some operation on the devbox                #
# ============================================== #

# shellcheck disable=SC2086
# shellcheck source=./man.env
source ${ROOT_DIR}/man/man.env
# shellcheck disable=SC2086
# shellcheck source=../util/*
source ${ROOT_DIR}/util/*

header "Devbox Manual"

OPEN="open"
HELP="help"

function print_info() {
    echo "This script uses the 'grip' python tool to render Markdown in a web browser."
    echo "Once you're finished reading the manual, kill the process with ^C"
}

function usage() {
    echo "Usage: $0 (${OPEN} | ${HELP})"
    echo -e "\t${OPEN} - Open up the manual in a web browser (^C to exit)"
    echo -e "\t${HELP} - Display this message"
    print_info
}

function open_manual() {
    grip -b "${ROOT_DIR}/man/docs/devbox_manual.md"
}

case $1 in
    ${OPEN} )
        open_manual
        ;;
    ${HELP} )
        usage
        ;;
    * )
        usage
        ;;
esac

exit 0