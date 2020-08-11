#!/bin/bash

if [[ "$*" =~ "-SecurityTypes None" ]]; then
    echo "Sorry...you are not allowed to run a vncserver with '-SecurityTypes None'"
    exit 1
fi

/etc/vncserver "$*"
