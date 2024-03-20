#!/usr/bin/env bash
# text encryption in cesar cipher

# ===========================
# $ ./cesar_cipher.sh -s <shift> -i <input file> -o <output file>
# ===========================


# file names
input_file=""
output_file=""

# cesar shift
declare -i shift=0


# function declaration - start
# function to encode characters in given file
encode () {
    echo "encoding for $1 $2 $3"

    #ROT-13
    tr "[A-Za-z]" "[N-ZA-Mn-za-m]" < $2 > $3
    
    #cat "$2" | tr "A-Za-z" "$(echo A-Za-z | tr "A-Za-z" "$(echo {A-Za-z} | sed "s/.*\n//")")"  > $3
    #cat "$2" | tr "A-Za-z" "$(echo A-Za-z | tr "A-Za-z" "$(echo {A-Za-z} | cut -b "$1"-26)$(echo {A-Za-z} | cut -b 1-"$(($1-1))")" > $3
    
    #cat $2 | tr "[A-Za-z]" "$(printf %${shift}s | tr ' ' 'A-Za-z' | tr 'A-Za-z' 'A-Za-z')$(printf %${shift}s | tr ' ' '[a-z]' | tr 'a-z' 'a-z')"  > $3
}

# function declaration - stop


# script - start
while getopts ":s:i:o:h" opt; do
    case $opt in 
        s)
            shift=$OPTARG
            ;;
        i)
            input_file="$OPTARG"
            ;;
        o)
            output_file="$OPTARG"
            ;;
        h)
            echo "Usage: -s <shift> -i <input file> -o <output file>"
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            ;;
        :)
            echo "No options specified - please use -s <shift> -i <input file> -o <output file> to use this script"
            ;;
    esac
done

if [ "$input_file" == "" ] || [ "$output_file" == "" ]; then
    echo "Please provide input and output filenames"
elif [ ! -s "$input_file" ]; then
    echo "Provide input file with text contents!"
else
    encode "$shift" "$input_file" "$output_file" 

fi

# script - stop 
