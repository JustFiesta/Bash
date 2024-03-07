#!/bin/bash
# simple calculator using getopts

# variables and config
operation=""
nums=()
d_flag=0

# script - start
while getopts "o:n:d" option; do

    case $option in
        o)  
            case $OPTARG in
                +)
                    operation="+"
                    ;;
                -) 
                    operation="-"
                    ;;
                \*)
                    operation="\*"
                    ;;
                \%)
                    operation="\%"
                    ;;
                \?)
                    echo "Invalid operation! Choose from these (+, -, *, %)"
                    exit 1
                    ;;
            esac
            ;;
        n)
            set -f # disable glob
            IFS=" " # split by space
            nums+=("$OPTARG")
            while [[ ${!OPTIND} && ${!OPTIND} != -* ]]; do
			    nums+=( "${!OPTIND}" )
			    ((OPTIND++))
            done
            ;;
        d)
            d_flag=1
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

fi    

if [ -n "$operation" ] && [ ${#nums[@]} -gt 1 ]; then
    result=${nums[0]}
    for ((i = 1; i < ${#nums[@]}; i++)); do
        case $operation in
            +) 
                result=$((result + ${nums[$i]}))
                ;;
            -) 
                result=$((result - ${nums[$i]}))
                ;;
            *) 
                echo "Invalid operation"
                exit 1
                ;;
            %) 
                result=$((result % ${nums[$i]}))
                ;;
        esac
    done
    echo "Result of $operation operation on given numbers: $result"
elif [ ${#nums[@]} -eq 0 ]; then
    echo "No numbers provided for calculation."
else
    echo "Invalid input for calculation."
fi

#script - end
