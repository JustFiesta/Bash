#!/bin/bash

for num in {1..100}; do


    if ! (( $num%15 )); then
        echo fizzBuzz
    elif ! (( $num%5 )); then
        echo fizz
    elif ! (( $num%3 )); then 
        echo buzz
    fi
done
