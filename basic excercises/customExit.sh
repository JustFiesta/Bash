#!/bin/bash
# overriding the exit and execute custom function
# this script copies provided file to "newfile.txt"

# global variables / configuration
TMPFILE="tmpfile.txt"
CONFIGFILE="scriptconfig.txt"

#trap (intercept signal and change it) cleanFilesExit EXIT
trap frenchLeave EXIT

# function declarations - start

# custom exit
frenchLeave () {
    echo "Exit intercepted"
    echo "Cleaning tmp and config files"
    rm -rf tmpfil*.txt scriptconf*.txt

    exit 420
}

# function declarations - stop

# script - start
echo "random stuff for tmpfile" /dev/random>$TMPFILE
echo "very important configuration...">$CONFIGFILE

if [ ! $# -eq 0 ]; then
    echo "Trying ot copy the indicated file before processing"
    cp -rf $1 newfile.txt 2>/dev/null
else
    echo "No file provided!"
    exit 1
fi
if [ $? -eq "0" ]; then
    echo "Copy succeded!"
else
    echo "Oops! something went wrong. Copy not made"
    exit 1
fi
# script - stop
