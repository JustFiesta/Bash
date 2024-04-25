#!/usr/bin/env bash
# script to modify text in file


# variables
input_file=""
output_file=""
word_a=""
word_b=""

# functions - start
# change letter size and save it to given file
toggle_case() {
    check_input_file
    tr '[:lower:][:upper:]' '[:upper:][:lower:]' < "$input_file" > "$output_file"
    echo "Case changed and saved to $output_file"
}

# check if input file exists
check_input_file() {
    if [ ! -f "$input_file" ]; then
        echo "Input file does not exist: $input_file"
        exit 1
    fi
}

# replace words and save it to given file
replace_word() {
    check_input_file

    # check if both words were given
    if [ -n "$word_a" ] && [ -n "$word_b" ]; then
        sed "s/$word_a/$word_b/g" "$input_file" > "$output_file"
        echo "Word $word_a replaced with $word_b and saved to $output_file"
    else
        echo "Provide non empty words! Check help (-h) for more information about -s"
        exit 1
    fi
}

# reverse text lines
reverse_lines() {
    check_input_file
    tac "$input_file" > "$output_file"
    echo "Text lines reversed and saved to $output_file"
}

# set all letter to lowercase
lowercase() {
    check_input_file
    tr "[:upper:]" "[:lower:]" < "$input_file" > "$output_file"
}

# set all letter to uppercase
uppercase() {
    check_input_file
    tr "[:lower:]" "[:upper:]" < "$input_file" > "$output_file"
}
# functions - stop

# script - start
while getopts ":vs:rluhi:o:" opt; do
    case $opt in 
        v)
            toggle_case
            ;;
        s)
            set -f # disable glob
            IFS=" " # split by space
            word_a="$OPTARG" # get first argument
            shift $((OPTIND - 1)) # shift optarg array pointer to next step/element
            word_b="$1"  # get next argument from option -s

            replace_word
            ;;
        r)
            reverse_lines
            ;;
        l)
            lowercase
            ;;
        u)
            uppercase
            ;;
        i)
            input_file="$OPTARG"
            ;;
        o)
            output_file="$OPTARG"
            ;;
        h)
            echo "Usage: "
            echo "          -v                      replace lowercase characters with uppercase and vice versa"
            echo "          -s <word_a> <word_B>    replaces word_A in file with word_B"
            echo "          -r                      reverse every line in text"
            echo "          -l                      convert every char to lovercase"
            echo "          -u                      convert every char to uppercase"
            echo "          -i <input_file>         specifies input file"
            echo "          -o <output_file>        specifies output file"
            echo "Note: Input and output filenames are mandatory!"
            ;;
        \?)
            echo "Invalid switch! Type -h for help"
            ;;
        :)
            echo "No switches provided! Check -h for help"
            ;;
    esac
done

exit 0
# script - stop