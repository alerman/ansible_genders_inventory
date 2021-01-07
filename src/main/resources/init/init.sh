#!/bin/bash

# ============================================ #
# This script both initializes and updates the #
# contents of the devbox container on startup. #
# It should be run INSIDE the actual devbox in #
# order to initialize or update the env.       #
# ============================================ #

# shellcheck disable=SC2086
# shellcheck source=./init.env
source ${ROOT_DIR}/init/init.env
# shellcheck disable=SC2086
# shellcheck source=../util/*
source ${ROOT_DIR}/util/*

header "Devbox Initialization"

function usage() {
    info "Usage: $0 <username> <uid>"
}

if [[ $# != 2 ]]; then
    usage
    exit 1
fi

USERNAME=$1
USER_ID=$2

USER_HOME="/home/${USERNAME}"

function rename_user() {
    info "Renaming preconfigured TEMP_USER (${TEMP_USER}) to ${USERNAME} with ID ${USER_ID}"
    if id -u "${TEMP_USER}" >/dev/null 2>&1; then
        # Rename preconfigured user to actual container owner's username
        usermod -l "${USERNAME}" "${TEMP_USER}" || return $?
        usermod -u "${USER_ID}" "${USERNAME}" || return $?
        usermod -d "${USER_HOME}" "${USERNAME}"
       # mv "/home/${TEMP_USER:?}/*" "${USER_HOME}/" # `:?` causes the command to fail if TEMP_USER is empty
    fi
}

function configure_mounted_dirs() {
    info "Configuring mounted directories"
    set_perms /data "${USERNAME}" "${USER_GROUP}" 755 --recursive || return $?
    make_dev_dir /data/git || return $?
    ln -s /data/git "${USER_HOME}/git"
    set_perms /datashare "${USERNAME}" "${USER_GROUP}" 755 --recursive || return $?

    cp /root/.Xclients "${USER_HOME}" || return $?
}

function configure_compose_ssh() {
    info "Configuring the root ssh key for the compose cluster"
    su - "${USERNAME}" -c "cp /tmp/ssh_keys/* ${USER_HOME}/.ssh"
    chmod 600 "${USER_HOME}/.ssh/*_rsa"
    chmod 644 "${USER_HOME}/.ssh/*_rsa.pub"

    su - "${USERNAME}" -c "ssh-add ${USER_HOME}/.ssh/compose_root_rsa"

    rm -rf /tmp/ssh_keys
}

function configure_git() {
    info "Configuring git"
    local _gitconfig_src="${PACKAGE_DIR}/git/gitconfig"
    local _gitconfig_dst="${USER_HOME}/.gitconfig"
    local _git_completion_src="${PACKAGE_DIR}/git/git-completion"
    local _git_completion_dst="${USER_HOME}/.git-completion.sh"

    sed -i "s/${TEMP_USER}/${USERNAME}/" "${_gitconfig_src}" || return $?
    backup_cp "${_gitconfig_src}" "${_gitconfig_dst}" || return $?
    backup_cp "${_git_completion_src}" "${_git_completion_dst}" || return $?
}

function configure_bash() {
    info "Configuring bash"
    local _bashrc_src="${PACKAGE_DIR}/bashrc.sh"
    local _bashrc_dst="${USER_HOME}/.bashrc"

    backup_cp "${_bashrc_src}" "${_bashrc_dst}" || return $?
}

function configure_firefox() {
    info "Configuring Firefox"
    local _bookmarks_src="${PACKAGE_DIR}/bookmarks-datawave.json"
    local _bookmarks_dst="${USER_HOME}/bookmarks-datawave.json"

    backup_cp "${_bookmarks_src}" "${_bookmarks_dst}" || return $?
    chmod 640 "${_bookmarks_dst}" || return $?
}

function configure_idea() {
    info "Configuring IntelliJ"
    local _idea_desktop_src="${PACKAGE_DIR}/idea/IntelliJ.desktop"

    cp "${_idea_desktop_src}" "${USER_HOME}/Desktop" || return $?
}

function configure_zsh() {
    info "Downloading Oh My Zsh"
    su $USERNAME sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    info "Configuring zsh"
    local _zshrc_src="${PACKAGE_DIR}/zshrc.sh"
    local _zshrc_dst="${USER_HOME}/.zshrc"

    backup_cp "${_zshrc_src}" "${_zshrc_dst}" || return $?

}

rename_user || error_exit "Failed to rename preconfigured user"
configure_mounted_dirs || error_exit "Failed to configure mounted directories"
configure_compose_ssh || error_exit "Failed to configure ssh for compose cluster"
configure_git || error_exit "Failed to configure git"
configure_bash || error_exit "Failed to configure bash"
configure_firefox || error_exit "Failed to configure firefox"
configure_idea || error_exit "Failed to configure IntelliJ"
configure_zsh || error_exit "Failed to configure zsh"
# Fix permissions in user's home directory
chown -R "${USERNAME}:${USER_GROUP}" "${USER_HOME}" || error_exit "Failed to fix permissions"
success "Successfully initialized the devbox..."
exit 0