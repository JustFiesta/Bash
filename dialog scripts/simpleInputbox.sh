#!/bin/bash
# demo if inpux box funcionality

# global variables / default values
INPUTBOX=${INPUTBOX=dialog}

# function declaration - start

# display input box to user
displayInputBox () {
    $INPUTBOX --title "$1" --inputbox "$2" "$3" "$4" 2>tmpfile.txt
}

# function declaration - stop

# script - start

displayInputBox "Display File Name" "Which file in the current directory do you want to display" "10" "20"

if [ "`cat tmpfile.txt`" != "" ]; then
    `cat tmpfile.txt`
else
    echo "Nothing to do"
fi

# script - stop 
