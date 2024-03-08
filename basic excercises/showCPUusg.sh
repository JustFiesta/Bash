#!/usr/env bash
#Goal is to create script for cron jobs

ps aux | awk 'END {print "Liczba uruchomionych procesów: " NR-1}'  # aux - show all processes (BSD syntax), trunkated to awk - with prints at end of ps number of processes (- first column)
top -b -n 1 | awk '/^%CPU/ {cpu=$2} /^MiB Mem/ {ram=$8} END {print "CPU: " cpu " %", "RAM: " ram}' #top opened once, trunkated to awk - it finds line starting with %CPU and MiB Mem, and assigns it to variable, than prints it

#after adding this script to machine add it's path to crontab -e
