#!/usr/bin/env bash
# -----------------
# domainTester: Get quick information about domains from whois

# Variables
report_file_name="Raport_DNS_$(date +%Y-%m-%d_%H-%M-%S).txt"
separator=""

# Function declarations
# Help/usage function
usage() {
    echo "Użycie: $0 -i <nazwa_pliku>"
    echo
    echo "Parametry:"
    echo "  -i <nazwa_pliku>   Ścieżka do pliku wejściowego zawierającego nazwy domen lub adresy IP."
    echo
    echo "Przykładowy plik wejściowy (domains.txt):"
    echo "  example.com"
    echo "  3.84.18.95"
    echo "  example.net"
    echo
    echo "Wspierane separatory nowej linii:"
    echo "  Nowa linia (\n)"
    echo "  Przecinek (,)"
    echo "  Średnik (;)"
}


# Check if domain has correct top level domain
validate_tld() {
    local domain=$1

    # Get the TLD using awk (assuming TLD is after the last dot)
    local tld=$(echo "$domain" | awk -F. '{print $NF}')

    # List of valid TLDs
    local valid_tlds=(
        com
        net
        org
        edu
        gov
        info
        biz
        pl
    )

    # Check if extracted TLD is in the list of valid TLDs
    for valid_tld in "${valid_tlds[@]}"; do
        if [ "$tld" == "$valid_tld" ]; then
            return 0  # Valid TLD found
        fi
    done

    return 1  # Invalid TLD
}



# Check domain name
check_domain() {
    local domain=$1
    local report=$2

    # Remove whitespaces and split lines by given separator
    domain=$(echo "$domain" | tr -d '[:space:]' | sed "s/[${separator}]$//")

    # Validate TLD
    if ! validate_tld "$domain"; then
        echo "$domain - nieprawidłowy TLD (prawidłowe: .com, .pl, net, etc)" >> "$report"
        echo "-----------------------------------" >> "$report"
        return
    fi

    # Get information about one domain
    sleep 0.5
    domain_info=$(whois "$domain")

    # Check whether domain is available or taken
    is_available=$(echo "$domain_info" | grep -E "^No match|^NOT FOUND|^Not fo|AVAILABLE|^No Data Fou|has not been regi|No entri")
    if [ -n "$is_available" ]; then 
        echo "$domain - wolna" >> "$report"
    else 
        # Get domain address
        ip=$(nslookup "$domain" | awk '/^Address: / { if ($2 !~ /#/) { print $2; exit } }')

        # Append name with IP to report file
        echo "$domain - zajęta, IP: $ip" >> "$report"

        # Get owner info
        owner_info=$(echo "$domain_info" | awk '/^(Registrant|Registrant Organization|OrgName|Organization|Owner|Creation Date):/ { gsub(/^Creation Date:/, "Data utworzenia:"); gsub(/^(Registrant Organization|OrgName|Organization|Owner):/, "Właściciel:"); print $0 }')

        # Check if any owner information is publicly available
        if [ -z "$owner_info" ]; then
            echo "Informacje o właścicielu nie są dostępne." >> "$report"
        else
            # Append organisation (owner) information
            echo "$owner_info" >> "$report"
        fi

        # Get expiration date
        expiration_date=$(echo "$domain_info" | awk -F': ' '/(Registrar Registration Expiration Date|Expiry Date)/ { print $2; exit }' | awk '{$1=$1};1')

        # Check if any expiration date information is publicly available
        if [ -n "$expiration_date" ]; then
            echo "Wygasa: $expiration_date" >> "$report"
        else
            # Append expiration date information
            echo "Informacja o dacie wygaśnięcia domeny niedostępna." >> "$report"
        fi
    fi 

    echo "-----------------------------------" >> "$report"
}



# Check for correct ip range
is_excluded_ip() {
    local ip=$1
    
    case $ip in
        10.* | 172.1[6-9].* | 172.2[0-9].* | 172.3[0-1].* | 192.168.* | 127.0.0.1 | 0.0.0.0 | 255.255.255.255)
            return 0  # IP is excluded
            ;;
        *)
            return 1  # IP is not excluded
            ;;
    esac
}


# Check domain IP
check_ip() {
    local ip=$1
    local report=$2

    # Remove whitespaces
    ip=$(echo "$ip" | tr -d '[:space:]' | sed "s/[${separator}]$//")

    # Check if IP is in excluded ranges
    if is_excluded_ip "$ip"; then
        echo "IP: $ip, należy do grup publicznych (lokalnych/diagnostycznych/rozgłoszeniowych)." >> "$report"
        echo "-----------------------------------" >> "$report"
        return
    fi

    # Run nslookup for given IP to check for its domain name
    domain=$(nslookup "$ip" | awk '/name = / {print $4}' | sed 's/\.$//')

    if [ -z "$domain" ]; then
        echo "IP: $ip, nie jest powiązane z żadną domeną." >> "$report"
        echo "-----------------------------------" >> "$report"
    else
        echo "IP: $ip, jest powiązane z domeną." >> "$report"
        check_domain "$domain" "$report"
    fi
}


# CLI with getopts
while getopts ":i:h" opt; do
    case ${opt} in
        i )
            input_file=$OPTARG
            ;;
        h) 
            usage
            exit 0
            ;;
        \? )
            echo "Nieznana opcja: -$OPTARG" 1>&2
            usage
            exit 1
            ;;
        : )
            echo "Brak argumentu dla: -$OPTARG" 1>&2
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

# Script - start
# Check if input file has been specified
if [ -z "$input_file" ]; then
    usage
fi

# Read the first line to check the separator
first_line=$(head -1 < "$input_file")

case "$first_line" in
    *$'\n'*)
        separator=$'\n'
        ;;
    *,*)
        separator=","
        ;;
    *";"*)
        separator=";"
        ;;
    *)
        echo "Nie można określić separatora w pliku."
        exit 1
        ;;
esac

# Check for dependencies
if ! command -v nslookup >/dev/null 2>&1; then
    echo "nslookup nie jest zainstalowane!"
    exit 1
fi

if ! command -v whois >/dev/null 2>&1; then
    echo "whois nie jest zainstalowane!"
    exit 1
fi

# Iterate over lines in file
while IFS=$separator read -r line || [[ -n "$line" ]]; do
    # Check either line is IP or Domain Name
    if [[ $line =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ || $line =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}${separator} ]]; then
        check_ip "$line" "$report_file_name"
    else
        check_domain "$line" "$report_file_name"
    fi
done < "$input_file"

exit 0
# Script - stop