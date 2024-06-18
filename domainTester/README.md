# Basic domain tester

Small domain tester.

It uses whois and nslookup for fetching on fly information about given domains (in file).

## Documentation

It is a simple while loop with even simpler CLI, stripping down each line in file and performing whois queries on each.

* only supports ONE argument - as contained in single file (support for *.txt and *.csv files.)
* accepts domains in format: www.domain.net, domain.net, IP

## How-to

1. Download/copy file
2. Add the excecute premissions with chmod +x (or in the numerical way)
3. Use it in shell: ./domainTester.sh -i test.csv