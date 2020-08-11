#!/bin/bash

# ============================================ #
# This script runs on a devbox container that  #
# has gone through all of the necessary setup. #
# It verifies that the devbox has all it needs #
# to run correctly.                            #
# ============================================ #

# shellcheck disable=SC2086
# shellcheck source=./doctor.env
source ${ROOT_DIR}/doctor/doctor.env
# shellcheck disable=SC2086
# shellcheck source=../util/*
source ${ROOT_DIR}/util/*

header "Devbox Doctor"

# Make sure this isn't running as root
if [[ ${EUID} == 0 ]]; then
    error_exit "Cannot run as root user"
fi

function check_for_ssh_key() {
    if [[ ! -e ~/.ssh ]]; then
        error_exit "Missing ssh key, run 'ssh-keygen' to resolve this issue"
    fi
}

function clone_repos() {
    pushd ~/git || error_exit "Could not access ~/git"
    for repo in "${GIT_REPOS[@]}"; do
        git clone ${repo} || error_exit "Could not clone repository...is your ssh key uploaded?"
    done
    popd || error_exit "Failed exiting ~/git"
}

check_for_ssh_key
clone_repos

success "Your devbox is ready for development!"
exit 0