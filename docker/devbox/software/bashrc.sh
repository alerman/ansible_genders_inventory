#!/bin/bash

# PERSONAL $HOME/.bashrc


#-------------------------------------------------------------
# Source global definitions (if any)
#-------------------------------------------------------------
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# shellcheck disable=SC1090
source ~/.git-completion.sh
# shellcheck disable=SC1090
source ~/.git-prompt.sh

#-------------------------------------------------------------
# Prompt configuration
#-------------------------------------------------------------

# Git branch added to command prompt
export GIT_PS1_SHOWDIRTYSTATE=1

# Change the prompt and the coloring
# shellcheck disable=SC2154
export PS1='[\u@\h] \[\e[0;36m\e[40m\][\w]\[\e[0m\e[0m\] $(__git_ps1 " (%s)")\$ '

#-------------------------------------------------------------
# User specific aliases and functions
#-------------------------------------------------------------
export USER=${USER:-$(whoami)}

# Run mvn in docker container to support easy versioning
export MVN_VERSION="maven:3.5.4-jdk-8"
export MAVEN_OPTS="-Xmx10240m"
MAVEN_REPO_VOLUME=${USER}_maven_repo
function mvn() {
    docker run -it --rm --name maven_runner \
           -v "${MAVEN_REPO_VOLUME}:/root/.m2" \
           -v "$(pwd):/usr/src/mymaven:z" \
           -w /usr/src/mymaven ${MVN_VERSION} \
           mvn "${MAVEN_OPTS}" "$@"
}

# User specific environment and startup programs
export IDEA_HOME=/opt/idea/current
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk/

PATH=$PATH:$HOME/bin:$IDEA_HOME/bin:$JAVA_HOME/bin:/opt/devbox
export PATH
