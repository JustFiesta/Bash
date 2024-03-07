#!/bin/bash
# simple file reading script

# script - start

echo "enter filename to read"
read FILE

i=1
# reading each line separetly
while read -r LINE; do
    echo "Line number $i contains: $LINE" 
    ((i++))
done < $FILE
# script - stop 
