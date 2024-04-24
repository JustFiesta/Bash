#!/usr/bin/env bash
# simple calculator using getopts

# variables and config
operation=""
nums=()
d_flag=0
h_flag=0

# script - start
while getopts "o:n:dh" option; do

    case $option in
        o)  
            case $OPTARG in
                "+")
                    operation="+"
                    ;;
                "-") 
                    operation="-"
                    ;;
                "*")
                    operation="*"
                    ;;
                "%")
                    operation="%"
                    ;;
                ?)
                    echo "Invalid operation! Choose from these (+, -, *, %)"
                    exit 1
                    ;;
            esac
            ;;
        n)
            set -f # disable glob
            IFS=" " # split by space
            nums+=("$OPTARG") # add first argument to array
            while [[ ${!OPTIND} ]]; do
			    nums+=( "${!OPTIND}" )
			    ((OPTIND++))
            done
            ;;
        d)
            d_flag=1
            ;;
        h)
            h_flag=1

            echo "Simple calculator"
            echo "-----------------"
            echo ""
            echo "# Usage:"
            echo "# ./calc.sh -o <operation> -n <numbers> [-d]"
            echo "#   -o <operation>: Specifies the arithmetic operation. Available operations: +, -, *, %"
            echo "#   -n <numbers>: Provides numbers separated by spaces on which the operation should be performed."
            echo "#   -d: Optional debugging flag, displays additional information."
            echo ""
            echo "# Examples of usage:"
            echo "# ./calc.sh -o + -n 3 5 7 -d   # Addition: 3 + 5 + 7 = 15"
            echo "# ./calc.sh -o - -n 10 5 -d   # Subtraction: 10 - 5 = 5"
            echo "# ./calc.sh -o \* -n 2 3 -d (need to escape)  # Multiplication: 2 * 3 = 6"
            echo "# ./calc.sh -o \% -n 7 3 -d (need to escape)  # Modulus: 7 % 3 = 1"
            echo ""
            echo "# Note that providing numbers after the -n option is required. The -d option is optional."
            echo "-----------------"
            echo ""
            ;;
        \?) 
            echo "Invalid option: -$OPTARG"
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

# check debug flag
if [ "$d_flag" -eq 1 ]; then
    echo "User: $USER"
    echo "Script: $0"
    echo "Operation: $operation"
    echo "Numbers: ${nums[*]}"
fi

# check if numbers were provided
if [ ${#nums[@]} -eq 0 ] && [ $h_flag != 1 ]; then
    echo "No numbers provided for calculation."
    exit 1
fi

# perform operation if one was given
if [ -n "$operation" ]; then
    result=${nums[0]}
    for ((i = 1; i < ${#nums[@]}; i++)); do
        case $operation in
            "+") 
                result=$( echo "$result+${nums[$i]}" | bc )
                ;;
            "-") 
                result=$( echo "$result-${nums[$i]}" | bc )
                ;;
            "*") 
                result=$( echo "$result*${nums[$i]}" | bc )
                ;;
            "%") 
                result=$( echo "$result%${nums[$i]}" | bc )
                ;;
        esac
    done
    echo "Result of $operation operation on given numbers: $result"
else
    echo "Invalid input for calculation." 
fi

#script - end
