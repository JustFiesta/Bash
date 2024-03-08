#!/usr/bin/env bash
# simple script for intercepting sertain signals

# script - start
clear

# when getting these two signals - display message and do not execute them
trap 'echo " - Please Press Q to Exit"' SIGINT SIGTERM

while [ "$CHOICE" != "Q" ] && [ "$CHOICE" != "q" ]; do
    echo "MAIN MENU"
    echo "========="
    echo "1) Choice one"
    echo "2) Choice two"
    echo "Q) Quit"
    echo ""
    read CHOICE

    clear
done

# script - stop 
