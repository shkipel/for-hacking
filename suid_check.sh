#!/bin/bash

echo "[*] Поиск всех SUID-бинарей в системе..."
SUID_BINARIES=$(find / -perm -4000 -type f 2>/dev/null)

echo "[+] Найдено $(echo "$SUID_BINARIES" | wc -l) SUID-файлов."

# Фильтры полезных утилит (можно расширять)
USEFUL=("less" "more" "vi" "vim" "nano" "awk" "find" "python" "perl" "env" "bash" "sh" "man" "tee" "cp" "tar" "gzip" "cat")

echo -e "\n[*] Поиск потенциально полезных бинарей:"
for bin in $SUID_BINARIES; do
    for keyword in "${USEFUL[@]}"; do
        if echo "$bin" | grep -q "$keyword"; then
            echo "[!] Найден интересный SUID: $bin"
        fi
    done
done

echo -e "\n[*] Поиск бинарей, вызывающих другие программы (возможно через system/popen)..."
for bin in $SUID_BINARIES; do
    strings "$bin" 2>/dev/null | grep -E "/bin/|/usr/bin/" | grep -Ev "ld|lib|/lib/" | sort -u | while read line; do
        echo "[?] $bin вызывает $line"
    done
done
