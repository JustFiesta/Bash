#!/bin/bash

for argument in $@
do
		if [ $argument -gt 10 ]; then
				echo "$argument"
		fi
done
