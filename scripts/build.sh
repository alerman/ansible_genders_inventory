#!/bin/bash

THIS_DIR=$(dirname "$(realpath $0)")
DEVBOX_DIR=$(realpath "${THIS_DIR}/..")

# NOTE: REGISTRY_URL is used to specify where to push the built images...must have trailing '/'
source ${THIS_DIR}/../src/main/resources/util/logging.sh

IDEA_URL="https://download.jetbrains.com/idea/ideaIC-2020.2.tar.gz"
POSTMAN_URL="https://dl.pstmn.io/download/latest/linux64"

COMPOSE_BASE_IMAGE_REP0="https://raw.githubusercontent.com/ejrgilbert/compose-base-image/master"
PRIV_KEY_URL="${COMPOSE_BASE_IMAGE_REP0}/base/resources/sshd/root_key/compose_root_rsa"
PUB_KEY_URL="${COMPOSE_BASE_IMAGE_REP0}/base/resources/sshd/root_key/compose_root_rsa.pub"

MAVEN="maven"
VANILLA="vanilla"
DEVBOX="devbox"
ALL="all"
HELP="help"

header "Docker Build Utility"

function usage() {
    echo "Usage: $0 [-v ver1 ver2 ...] [-p] -- (${ALL} | ${MAVEN} | ${VANILLA} | ${DEVBOX})"
    echo -e "\t${ALL} - if you would like to build the entire project"
    echo -e "\t${MAVEN} - if you would like to build the maven portion of the project"
    echo -e "\t${VANILLA} - if you would like to build the ${VANILLA} docker image"
    echo -e "\t${DEVBOX} - if you would like to build the ${DEVBOX} docker image (based on ${VANILLA} image)"
    echo -e "\t${HELP} - to see this message"
    echo "Options:"
    echo -e "\t-v - What versions to tag the images as"
    echo -e "\t-p - Pass this option if you want to push to the REGISTRY...MUST HAVE -v IF USING THIS OPTION"
    note "Make sure you  pass the '--' if you use any of the above options (-v parsing causes this)"
    exit 1
}

function build_failed() {
    error_exit "Build of $1 failed"
}

function download_tar() {
    if [[ $# != 2 ]]; then
        error_exit "Usage: download_tar <url> <dst>"
    fi

    local _url=$1
    local _dst=$2

    if [[ ! -e $(dirname "${_dst}") ]]; then
        mkdir -p "${_dst}"
    fi

    if [[ ! -e "${_dst}" ]]; then
        wget "${_url}" -O "${_dst}"
        check_success $? "Failed to download tar from ${_url}"
    fi
}

function download_blob() {
    if [[ $# != 2 ]]; then
        error_exit "Usage: download_blob <url> <dst>"
    fi

    local _url=$1
    local _dst=$2

    if [[ ! -e $(dirname "${_dst}") ]]; then
        mkdir -p "$(dirname "${_dst}")"
    fi

    if [[ ! -e "${_dst}" ]]; then
        wget "${_url}" -O "${_dst}"
        check_success $? "Failed to download blob from ${_url}"

        echo "[$(date -f )] Downloaded ${_dst} from ${_url}" > "$(dirname "${_dst}")/$(basename "${_dst}").info"
    fi
}

function build_maven() {
    info "Building Maven project"
    if ! mvn -f ${DEVBOX_DIR}/pom.xml clean install; then
        build_failed "Maven project"
    fi
    info "Completed building maven project"
}

function build_vanilla() {
    info "Building ${VANILLA} docker image"
    if ! docker build -t ${VANILLA} ${THIS_DIR}/../docker/${VANILLA}; then
        build_failed ${VANILLA}
    fi
    success "Completed building ${VANILLA} docker image"
}

function build_devbox() {
    info "Building ${DEVBOX} docker image"
    local software_dir="${THIS_DIR}/../docker/devbox/software"

    # Download the IntelliJ and Postman tars (too large for git's max file size)
    download_tar "${IDEA_URL}" "${software_dir}/idea/idea.tar.gz"
    download_tar "${POSTMAN_URL}" "${software_dir}/postman/postman.tar.gz"
    # Download the 'compose-base-image' root key
    download_blob "${PRIV_KEY_URL}" "${software_dir}/ssh_keys/compose_root_rsa"
    download_blob "${PUB_KEY_URL}" "${software_dir}/ssh_keys/compose_root_rsa.pub"

    if ! docker build -t ${DEVBOX} ${THIS_DIR}/../docker/${DEVBOX}; then
        build_failed ${DEVBOX}
    fi
    success "Completed building ${DEVBOX} docker image"
}

function tag_image() {
    local _type=$1
    if [[ -z ${DEV_BOX_VERSIONS[*]} ]]; then
        return
    fi

    info "Tagging ${_type} docker images as: [ ${DEV_BOX_VERSIONS[*]} ]"
    for v in "${DEV_BOX_VERSIONS[@]}"; do
        docker tag "${_type}" "${REGISTRY_URL}${_type}:$v" || error_exit "Failed to tag ${REGISTRY_URL}${_type}:$v"
    done
    success "Completed tagging docker images"
}

function push_image() {
    local _type=$1
    if [[ "${PUSH}" != "true" ]]; then
        return
    fi

    info "Pushing ${_type} docker images"
    for v in "${DEV_BOX_VERSIONS[@]}"; do
        docker push "${REGISTRY_URL}${_type}:$v" || error_exit "Failed to push ${REGISTRY_URL}${_type}:$v"
    done
    success "Completed pushing docker images"
}

function run_vanilla() {
    build_vanilla
    tag_image "${VANILLA}"
    push_image "${VANILLA}"
}

function run_devbox() {
    build_devbox
    tag_image "${DEVBOX}"
    push_image "${DEVBOX}"
}

function run_all() {
    run_vanilla
    build_maven
    run_devbox
}

function trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    printf '%s' "$var"
}

if [[ $* =~ ${HELP} ]]; then
    usage
fi

# From: https://medium.com/@Drew_Stokes/bash-argument-parsing-54f3b81a6a8f
PARAMS=""
while (( "$#" )); do
    case "$1" in
        -v|--version )
            if [ -z "$2" ]; then
                error_exit "Argument required for $1"
            fi
            shift 1

            while [ -n "$1" ] && [ "${1:0:1}" != "-" ]; do
                DEV_BOX_VERSIONS+=("$1")
                shift 1
            done
            ;;
        -p|--push )
            PUSH="true"
            shift
            ;;
        -- )
          shift 1
          ;;
        -*|--*) # unsupported flags
            echo "uh oh"
            error_exit "Unsupported flag $1"
            ;;

        -? )
            usage
            ;;
        *) # preserve positional arguments
            PARAMS="$PARAMS ${1}"
            shift
            ;;
    esac
done
# set positional arguments in their proper place
PARAMS=`echo $PARAMS | xargs`
eval set -- "$PARAMS"

if [[ ${#PARAMS[@]} -ne 1 ]]; then
    error "Expecting one positional argument specifying which image(s) to build"
    usage
fi

if [[ "${PUSH}" == "true" && -z ${DEV_BOX_VERSIONS[*]} ]]; then
    error "The push (-p) option must be paired with tag versions (-v)"
    usage
fi

case ${PARAMS[0]} in
    ${MAVEN} )
        build_maven
        ;;
    ${VANILLA} )
        run_vanilla
        ;;
    ${DEVBOX} )
        run_devbox
        ;;
    ${ALL} )
        run_all
        ;;
    * )
        usage
        ;;
esac

exit 0
