#!/bin/bash

# shellcheck disable=SC2086
# shellcheck source=../util/logging.sh
source ${ROOT_DIR}/util/logging.sh

function validate_id() {
    if [[ $# -ne 1 ]]; then
        error_exit "Usage: validate_id <id>"
    fi
    local _id=$1

    if [[ ! "${_id}" =~ ^[a-z]{3,4}[a-z0-9]{0,3}$ ]]; then
        error_exit "${_id} is not a valid id"
    fi
}

function validate_fullname() {
    if [[ $# -ne 1 ]]; then
        error_exit "Usage: validate_fullname <fullname>"
    fi
    local _fullname=$1

    if [[ ! "${_fullname}" =~ ^[[:alpha:]]+[[:space:]][[:alpha:]]+([[:space:]][[:alpha:]]+)?{0,3}$ ]]; then
        error_exit "${_fullname} is not a valid fullname"
    fi
}
