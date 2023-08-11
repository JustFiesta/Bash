ps aux | awk 'END {print "Liczba uruchomionych procesów: " NR-1}'
top -b -n 1 | awk '/^%CPU/ {cpu=$2} /^MiB Mem/ {ram=$8} END {print "CPU: " cpu " %", "RAM: " ram}'
