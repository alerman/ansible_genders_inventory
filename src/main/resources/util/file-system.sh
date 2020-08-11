#!/bin/bash

# shellcheck disable=SC2086
# shellcheck source=../util/logging.sh
source ${ROOT_DIR}/util/logging.sh

function validate_perms() {
    if [[ $# -lt 4 ]]; then
        error_exit "Usage: validate_perms <dir> <own> <grp> <octal_mod> (--recursive)"
    fi
    local dir=$1
    local own=$2
    local grp=$3
    local mod=$4

    if ! id -u "${own}"; then
        error_exit "User '${own}' does not exist"
    fi

    if ! getent group "${grp}"; then
        error_exit "Group '${grp}' does not exist"
    fi

    if [[ ! ${mod} =~ ^[0-7]{3,4}$ ]]; then
        error_exit "'${mod}' is not a valid octal_mod"
    fi
}

# Set permissions/ownership of a directory
function set_perms {
    validate_perms "$@" >/dev/null 2>&1

    local dir=$1
    local own=$2
    local grp=$3
    local mod=$4

    if [[ $5 == "--recursive" ]]; then
        ARG="-R"
    fi

    chown ${ARG} "${own}" "${dir}" || return 1
    chgrp ${ARG} "${grp}" "${dir}" || return 1
    chmod ${ARG} "${mod}" "${dir}" || return 1

    return 0
}

# Create a directory with ownership and permissions
function create_directory() {
    validate_perms "$@" >/dev/null 2>&1

    local dir=$1
    local own=$2
    local grp=$3
    local mod=$4

    info "Creating ${dir} (own=${own},grp=${grp},mod=${mod})"

    mkdir "${dir}"
    set_perms "$@"
}

function make_dev_dir() {
    if [[ $# -ne 1 ]]; then
        error_exit "Usage: make_dev_dir <dir>"
    fi
    local dir=$1

    # Keep timestamped history
    [ -d "$dir" ] && mv "$dir" "$dir.$(date +"${HIST_TS_FORMAT}")"
    create_directory "${dir}" "${USERNAME}" "${USER_GROUP}" 755 --recursive
#    su - "${USERNAME}" -c "ln -snf $dir $(basename "$dir")"
    echo "|- ${dir}"

    # Retain timestamped history
    find "${dir%/*}" -maxdepth 1 -name "${dir##*/}.*" -type d -atime +"${HIST_RETAIN_DAYS}" -print0 | \
              xargs -0 rm -rf
}

function backup_cp() {
    if [[ $# -ne 2 ]]; then
        error_exit "Usage: backup_cp <src> <dst>"
    fi
    local _src=$1
    local _dst=$2
    local _postfix=".old"

    # Retain a backup of the original
    if [[ -e ${_dst} ]]; then
        cp -p "${_dst}" "${_dst}${_postfix}" || return $?
    fi

    # Copy src to the dst
    cp "${_src}" "${_dst}" || return $?
}
