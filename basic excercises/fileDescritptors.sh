#!/bin/bash
# demo of file descriptors read and write

# global variables / configuration
FILE=$1
i=1

# script - start
# creatning new descriptor at number 5 (similar to 0 - stdin, 1 stdout, 2 - stderr)
# < - read
# > - write
# <> - read and write

# open file descriptor
exec 5<>$FILE

while read -r LINE; do
    echo "Line $i contains: $LINE"
    ((i++))
done <&5

echo "file was read on: `date`" >&5

#close file descriptor
exec 5>&-

# script - stop 
