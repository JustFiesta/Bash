#!/usr/bin/env bash
# text encryption in cesar cipher
# supports only all a-zA-Z letters up to ROT26 

# ===========================
# $ ./cesar_cipher.sh -s <shift> -i <input file> -o <output file>
# ===========================


# file names
input_file=""
output_file=""

# global variables
declare -i shift=0

lowercase_alphabet="abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz"
uppercase_alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ"

# function declaration - start
# function to encode characters in given file
encode () {
    tr "${lowercase_alphabet:0:26}" "${lowercase_alphabet:${shift}:26}" < "$1" | tr "${uppercase_alphabet:0:26}" "${uppercase_alphabet:${shift}:26}" > "$2"
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

#check for correct filenames
if [ "$input_file" == "" ]; then
    echo "Please provide input filename"
    exit 1
fi

if [ "$output_file" == "" ]; then
    echo "Please provide output filename"
    exit 1
fi

# get filetype
file_type=$(file -b --mime-type "$input_file")

if [[ $file_type != "text/plain" ]]; then # check for file type (must be text)
    echo "Input file is not a text file!"
    exit 1
fi

if [ $shift -gt 26 ] || [ $shift -lt 0 ]; then # check for positive num in (0-26 range)
    echo "Provide valid shift! (0-26)"
    exit 1 
fi

encode "$input_file" "$output_file" 

exit 0

# script - stop 