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

export PATH=$PATH:$HOME/bin:$M2_HOME/bin:$IDEA_HOME/bin:$JAVA_HOME/bin:/opt/devbox

export MAVEN_OPTS="-Xmx10240m"

# User specific environment and startup programs
export IDEA_HOME=/opt/idea/current
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk/
export M2_HOME=/opt/mvn/current
