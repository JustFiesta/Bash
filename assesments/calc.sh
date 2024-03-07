#!/bin/bash
# simple calculator using getopts

# variables and config
operation=""
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
    esac
done

shift $(( OPTIND-1 ))

echo "The whole list of values is '${nums[@]}'"

echo "given nums: "
for i in "${nums[@]}"; do
    echo -n " ${i}"
done 

if [ ! $d_flag -eq 1 ]; then
    case $operation in
        +)
            
            ;;
        -) 

            ;;
        \*)

            ;;
        \%)

            ;;
    esac

fi    
