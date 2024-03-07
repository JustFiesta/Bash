#!/bin/bash
# infobox (dialog script) demo

# global variables
# function declarations
function showDialogMessage(){
	echo "test"
	`dialog --stdout --infobox "$1" $2 $3 `
}

# script start - display dialog box
if [ "$1" == "reboot" ]; then
	showDialogMessage "System will reboot!" 20 40
	sleep 5
	echo "Rebooting..."
else
	echo "Nothing fun..."
fi
# script end
