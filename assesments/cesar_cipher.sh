#!/usr/bin/env bash
# text encryption in cesar cipher

# ===========================
# $ ./cesar_cipher.sh -s <shift> -i <input file> -o <output file>
# ===========================


# file names
input_file=""
output_file=""

# global variables
declare -i shift=0

alphabet=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ

# function declaration - start
# function to encode characters in given file
encode () {
    echo "encoding for shift: $1, input: $2, output: $3"

    tr "${alphabet:0:26}" "${alphabet:${shift}:26}"

    #ROT-13
    #tr "[A-Za-z]" "[N-ZA-Mn-za-m]" < $2 > $3
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
