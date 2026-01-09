#!/usr/bin/env bash

echo "Start of fibbonaci sequence for $1"

function fib() {	

    if [[ $1 -lt 0 ]]; then
        echo 0
    elif [[ $1 -eq 1 ]]; then
        echo 1
    else
       echo $[ `fib $[$1-2]` + `fib $[$1 - 1]` ] 
    fi

#    case $num in
#
#        :)
#            echo "No number was provided!"
#            return 0
#            exit 1
#            ;;
#		"0")
#            #echo $((0))
#			return 0
#            exit
#            ;;
#		"1")
#           # echo $((1))
#			return 1
#            exit
#            ;;
#		*)
#            return $[ `fib $[$1-2]` + `fib $[$1 - 1]` ] 
#			;;
#	esac					
}
fib $1
