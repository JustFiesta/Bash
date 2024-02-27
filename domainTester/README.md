# Basic domain tester

Small domain tester.

It uses nslookup for fetching on fly information about given domains (in file).

## Documentation

It is a simple while loop, stripping down each line in file and performing netstat queries on each.

* only supports ONE argument - as one domain OR multiple domains contained in single file
* accepts domains in format: www.domain.net, domain.net

## How-to

1. Download/copy file
2. Add the excecute premissions with chmod +x (or in the numerical way)
3. Use it in shell: ./testDomains.sh your_file_containing_domains.txt