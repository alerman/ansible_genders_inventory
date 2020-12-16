#!/bin/bash

# =============================================== #
# This script gets run on the devbox HOST machine #
# to create, update, and/or start the devbox.     #
# =============================================== #
source ../src/main/resources/util/logging.sh

USERNAME=$(id -u -n)
USER_ID=$(id -u)

DATA_CONTAINER_NAME=${USERNAME}_data_container
MAVEN_VOLUME=${USERNAME}_maven_repo
DEV_BOX_NAME=${USERNAME}_dev_box
DEV_BOX_VERSION=latest

DEVBOX_DATA_DIR="/srv/data1/datawave/devbox_data"
HOME_DIR="${DEVBOX_DATA_DIR}/home/${USERNAME}"
DATA_DIR="${DEVBOX_DATA_DIR}/data/${USERNAME}"

header "Devbox Control Script"

function usage() {
    echo "Usage: $0 [-n <dev_box_name>] [-v <version>]"
    echo -e "\tOptions:"
    echo -e "\t-v: Override the default version (${DEV_BOX_VERSION}) of the devbox release you want to start up"
    echo -e "\t-n: Override the default name (${DEV_BOX_NAME}) of the devbox container"
    exit 1
}

while getopts 'v:n:' opt
do
    case "${opt}" in
        v)
            DEV_BOX_VERSION="${OPTARG}"
            ;;
        n)
            DEV_BOX_NAME="${OPTARG}"
            ;;
        ?)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

# =============== #
# Setup user dirs #
# =============== #
function setup_user_dirs() {
    sudo mkdir -p "${HOME_DIR}"
    check_success $? "Failed to create ${HOME_DIR}..."
    sudo mkdir -p "${DATA_DIR}"
    check_success $? "Failed to create ${DATA_DIR}..."
}

# ========================= #
# Setup user data container #
# ========================= #
function setup_user_data_container() {
    # EXISTS is the output of the below command, not the return code...
    EXISTS=$(docker ps -f "name=${DATA_CONTAINER_NAME}" -a | grep -v IMAGE -c)
    if [[ $EXISTS == 0 ]]; then
        info "Data container not found. Creating..."
        docker run -v "${HOME_DIR}:/home/${USERNAME}:z" \
                   -v "${DATA_DIR}:/data:z" \
                   --name "${DATA_CONTAINER_NAME}" \
                   alpine:latest \
                   touch "/home/${USERNAME}/init_data_container"
        check_success $? "Failed to create data container..."
    else
        info "Data container found, continuing..."
    fi
}

# ============================================= #
# Setup user Maven container for artifact reuse #
# ============================================= #
function setup_maven_container() {
    if ! docker volume ls | grep "${MAVEN_VOLUME}"; then
        info "Maven volume not found. Creating..."
        docker volume create "${MAVEN_VOLUME}"
        check_success $? "Failed to create maven volume..."
    else
        info "Maven volume found, continuing..."
    fi
}

function start_devbox() {
    CURRENT_VERSION=$(docker ps -f "name=^/${DEV_BOX_NAME}\$" -a --format '{{.Image}}' | cut -d: -f2)
    if [[ "$CURRENT_VERSION" != "${DEV_BOX_VERSION}" ]]; then
        CURRENT_BOX=$(docker ps -f "name=^/${DEV_BOX_NAME}\$" -a --format '{{.Names}}')
        if [ -n "${CURRENT_BOX}" ]; then
            warn "Devbox has wrong version. Rename it and create a new one"
            TIME=$(date +%Y%m%d%H%M%S)
            docker rename "$CURRENT_BOX" "${CURRENT_BOX}_${TIME}"
            check_success $? "Failed to rename $CURRENT_BOX to ${CURRENT_BOX}_${TIME}..."
        else
            info "Devbox not found...creating..."
        fi

#        docker pull "devbox:${DEV_BOX_VERSION}"
        docker run -dt -P --expose 8443 --expose 5900-5999 --name "${DEV_BOX_NAME}" \
            --privileged=true \
            --volumes-from "${DATA_CONTAINER_NAME}" \
            -v /tmp:/hostTmp:z \
            -v /srv/logs:/srv/logs:z \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -v /etc/yum.repos.d:/etc/yum.repos.d:ro \
            --net host \
            --shm-size=1gb \
            "devbox:${DEV_BOX_VERSION}"
        check_success $? "Failed to startup devbox:${DEV_BOX_VERSION} as ${DEV_BOX_NAME}..."
        docker exec "${DEV_BOX_NAME}" /opt/devbox/devbox init "${USERNAME}" "${USER_ID}"
        check_success $? "Failed to initialize devbox running as ${DEV_BOX_NAME}..."

        # Check that you can run docker and docker-compose commands
        docker exec --user="${USERNAME}" "${DEV_BOX_NAME}" docker ps >/dev/null
        check_success $? "Unable to run docker command on devbox...please investigate..."
    else
        info "Dev box found...starting..."
        docker start "${DEV_BOX_NAME}"
        check_success $? "Failed to startup devbox ${DEV_BOX_NAME}..."
    fi
}

function update_docker_gid() {
    DOCKER_ID=$(getent group docker | awk -F':' '{ print $3 }')
    info "Changing docker GID to ${DOCKER_ID}..."
    docker exec "${DEV_BOX_NAME}" groupmod -g "${DOCKER_ID}" docker

    check_success $? "Failed change docker GID to ${DOCKER_ID}..."
}

setup_user_dirs
setup_user_data_container
setup_maven_container
start_devbox
update_docker_gid

success "Started devbox:${DEV_BOX_VERSION} as ${DEV_BOX_NAME}"
