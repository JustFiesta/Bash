#!/bin/bash
# interactive demo for dialog command

# global variables / default variables
MENUBOX=${MENUBOX=dialog}

# function declarations - start

# display the message box with our own message
displayMenu() {
	$MENUBOX --title "MAIN MENU" --menu "Use arrow keys to Move and enter to select your choice" 15 45 4 1 "Display Hello World" 2 "Display Goodbye World" 3 "Display nothing" X "Exit" 2>choice.txt #2>choice.txt redirects std err to file so we can view menu 
}
# function declarations - end


# script start
displayMenu

case "`cat choice.txt`" in
	1) #clear
		echo "Hello World"
		;;
	2)# clear
	        echo "Goodbye World"
	        ;;
	3)# clear
	        echo "Nothing"
	        ;;
	X) echo "Exitting..."
	      	clear
		exit 0
	      	;;	      
esac
# script end
