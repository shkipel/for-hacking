#!/bin/bash

echo "[*] Searching for all SUID binaries on the system..."
SUID_BINARIES=$(find / -perm -4000 -type f 2>/dev/null)

echo "[+] Found $(echo "$SUID_BINARIES" | wc -l) SUID files."

# List of potentially useful binaries
USEFUL=("less" "more" "vi" "vim" "nano" "awk" "find" "python" "perl" "env" "bash" "sh" "man" "tee" "cp" "tar" "gzip" "cat")

echo -e "\n[*] Looking for potentially useful SUID binaries:"
for bin in $SUID_BINARIES; do
    for keyword in "${USEFUL[@]}"; do
        if echo "$bin" | grep -q "$keyword"; then
            echo "[!] Interesting SUID binary found: $bin"
        fi
    done
done

echo -e "\n[*] Checking if any SUID binaries call other executables (via system()/popen/etc):"
for bin in $SUID_BINARIES; do
    strings "$bin" 2>/dev/null | grep -E "/bin/|/usr/bin/" | grep -Ev "ld|lib|/lib/" | sort -u | while read line; do
        echo "[?] $bin calls $line"
    done
done
