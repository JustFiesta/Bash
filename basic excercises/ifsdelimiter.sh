#!/usr/bin/env bash
# Reading files with custom delimeters 

# global variables / configuration
FILE=$1
DELIM=$2

IFS="$DELIM"

# script - start
while read -r CPU MEMORY DISK; do
    echo "CPU: $CPU"
    echo "Memory: $MEMORY"
    echo "Disk: $DISK"
done <"$FILE"

# script - stop 
