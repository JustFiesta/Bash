#!/bin/bash

# Sprawdzenie, czy podano nazwę pliku z domenami jako argument
if [ $# -eq 0 ]; then
    echo "Użycie: $0 <nazwa_pliku>"
    exit 1
fi

# Pętla przechodząca przez każdą linię w podanym pliku
while IFS= read -r domain || [[ -n "$domain" ]]; do
    # Usunięcie białych znaków na początku i na końcu linii
    domain=$(echo "$domain" | tr -d '[:space:]')
    # Wykonanie nslookup dla domeny, aby uzyskać jej adres IP
    ip=$(nslookup "$domain" | awk '/^Address: / { if ($2 !~ /#/) { print $2; exit } }')
    # Sprawdzenie, czy nie ma adresu IP, co oznacza, że domena wygasła
    if [ -z "$ip" ]; then
        echo "Domena $domain wygasła."
    else
        # Wyświetlenie adresu IP dla danej domeny
        echo "Domena $domain istnieje pod adresem: $ip"
        # Wyświetlenie informacji o właścicielu domeny
        echo "Właściciel domeny $domain to:"
        owner_info=$(whois "$domain" | grep -E '^Registrant|^OrgName|^owner')
        # Sprawdzenie, czy informacje o właścicielu są dostępne
        if [ -z "$owner_info" ]; then
            echo "Informacje o właścicielu nie są dostępne."
        else
            echo "$owner_info"
        fi
        # Wyświetlenie daty wygaśnięcia domeny
        expiration_date=$(whois "$domain" | awk -F':' '/Expiration Date:/ { print $2 }' | awk '{$1=$1};1')
        if [ -n "$expiration_date" ]; then
            echo "Data wygaśnięcia domeny: $expiration_date"
        else
            echo "Informacja o dacie wygaśnięcia domeny niedostępna."
        fi
        # Użycie traceroute do określenia liczby przeskoków do osiągnięcia domeny
        hops=$(traceroute -m 10 -q 1 -n "$domain" | grep -vE '^traceroute' | wc -l)
        echo "Liczba przeskoków potrzebna do osiągnięcia domeny: $hops"
    fi
    echo "-----------------------------------"
done < "$1"
