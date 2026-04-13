#!/bin/bash

greet_user() {
    local USERNAME=$1
    echo "Hello, $USERNAME. Welcome to olympus."
}

check_disk() {
    local THRESHOLD=$1
    local USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
    if [ "$USAGE" -gt "$THRESHOLD" ]; then
        echo "WARNING: Disk usage is at ${USAGE}%"
    else
        echo "OK: Disk usage is at ${USAGE}%"
    fi
}

greet_user "Alberto"
check_disk 80
