#!/bin/bash
# Generate basic information about system, network and current user

echo "======================="
echo "$(date)"
echo "======================="
echo "Current user: $(whoami)"
echo "======================="
echo "Hostname: $(hostname), IP: $(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')"
echo "External IP: $(wget -qO- https://ipecho.net/plain ; echo)"
echo "======================="
echo "System name and version: $(uname -sr)"
echo "======================="
echo "Uptime: $(uptime)"
echo "======================="
echo "Disk space: "
df -hai
echo "======================="
free -h
echo "======================="
cat /proc/cpuinfo | grep "MHz"
lscpu | grep "^CPU(s)"
