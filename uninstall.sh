#!/bin/sh
set -e

# certgun uninstaller

BINARY="certgun"
LOCATIONS="/usr/local/bin/$BINARY $(go env GOPATH 2>/dev/null)/bin/$BINARY"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

removed=0
for path in $LOCATIONS; do
    if [ -f "$path" ]; then
        printf "${GREEN}[certgun]${NC} Removing %s\n" "$path"
        rm -f "$path" 2>/dev/null || sudo rm -f "$path"
        removed=1
    fi
done

if [ "$removed" = "0" ]; then
    printf "${RED}[certgun]${NC} certgun not found in standard locations.\n"
    exit 1
fi

printf "${GREEN}[certgun]${NC} Uninstalled successfully.\n"
