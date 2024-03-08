#!/usr/bin/env bash
# interactive demo for dialog command

# global variables / default variables
MSGBOX=${MSGBOX=dialog}
TITLE="Simple demo"
MESSAGE="Hello traveler!"
XCOORD=10
YCOORD=20

# function declarations - start

# display the message box with our own message
displayMsgBox() {
	$MSGBOX --title "$1" --msgbox "$2" "$3" "$4"
}
# function declarations - end

# script start
if [ "$1" == "shutdown" ]; then
	displayMsgBox "Warning!" "Please press OK when you are ready to close the system" "10" "30"
	echo "Shutting down..."
	sleep 2
	clear
else
	displayMsgBox "Boring..." "Nothing fun" "10" "30"
	clear
fi
# script end
