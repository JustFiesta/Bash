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
    echo "  192.0.2.1"
    echo "  example.net"
    echo
    echo "Wspierane separatory nowej linii:"
    echo "  Nowa linia (\n)"
    echo "  Przecinek (,)"
    echo "  Średnik (;)"
}


# Check domain name
check_domain() {
    local domain=$1
    local report=$2

    # Remove whitespaces and split lines by given separator
    domain=$(echo "$domain" | tr -d '[:space:]' | sed "s/[${separator}]$//")

    # Get information about one domain
    sleep 0.5
    domain_info=$(whois "$domain")

    # Check wether domain is avalible or taken
    is_avalible=$(echo "$domain_info" | grep -E "^No match|^NOT FOUND|^Not fo|AVAILABLE|^No Data Fou|has not been regi|No entri")
    if [ -n "$is_avalible" ]; then 
        echo "$domain - wolna" >> "$report"

    else 
        # Get domain address
        ip=$(nslookup "$domain" | awk '/^Address: / { if ($2 !~ /#/) { print $2; exit } }')

        # Append name with IP to report file
        echo "$domain - zajęta, IP: $ip" >> "$report"

        # Get owner info
        owner_info=$(echo "$domain_info" | awk '/^(Registrant|Registrant Organization|OrgName|Organization|Owner|Creation Date):/ { gsub(/^Creation Date:/, "Data utworzenia:"); gsub(/^(Registrant Organization|OrgName|Organization|Owner):/, "Właściciel:"); print $0 }')

        # Check if any owner information is publicly avalible
        if [ -z "$owner_info" ]; then
            echo "Informacje o właścicielu nie są dostępne." >> "$report"
        else
            # Append organisation (owner) information
            echo "$owner_info" >> "$report"
        fi

        # Get expiration date
        expiration_date=$(echo "$domain_info" | awk -F': ' '/(Registrar Registration Expiration Date|Expiry Date)/ { print $2; exit }' | awk '{$1=$1};1')

        # Check if any expiration date information are publicly avalible
        if [ -n "$expiration_date" ]; then
            echo "Wygasa: $expiration_date" >> "$report"
        else
            # Append expiration date information
            echo "Informacja o dacie wygaśnięcia domeny niedostępna." >> "$report"
        fi
    fi 

    echo "-----------------------------------" >> "$report"
}

# Check domain IP
check_ip() {
    local ip=$1
    local report=$2

    # Remove whitespaces
    ip=$(echo "$ip" | tr -d '[:space:]' | sed "s/[${separator}]$//")

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