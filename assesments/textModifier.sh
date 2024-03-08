#!/usr/bin/env bash
# script to modify text





while getopts ":vs:rluhi:o:" opt; do
    case $opt in 
        v)
            echo "v"
            ;;
        s)
            echo "s"
            ;;
        r)
            echo "r"
            ;;
        l)
            echo "l"
            ;;
        u)
            echo "u"
            ;;
        i)
            echo "i"
            ;;
        o)
            echo "o"
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
            ;;
        \?)
            echo "Invalid switch! Type -h for help"
            ;;
        :)
            echo "No switches provided! Check -h for help"
            ;;
    esac
done
