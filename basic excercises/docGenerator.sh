#!/usr/bin/env bash
# script for creatning very simple listing of all scripts in current directory

# global variables / configuration
DOCFILE="script_listing"

# this will make listing script document like and readable as executable
echo "#!/bin/more" > $DOCFILE

ls *.sh > tmplisting.txt

# function declaration - start
# function declaration - stop

# script - start
while IFS= read -r FILENAME; do
    if [ -f "$FILENAME" ]; then
        echo "=====================" >> "$DOCFILE"
        echo "SCRIPT NAME: $FILENAME" >> "$DOCFILE"
        echo "=====================" >> "$DOCFILE"
        echo ""
        echo "`cat $FILENAME`" >> "$DOCFILE"
    fi
done < tmplisting.txt

chmod 755 "$DOCFILE"
rm tmplisting.txt

# script - stop 
