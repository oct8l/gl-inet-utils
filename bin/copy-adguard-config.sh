#!/bin/bash

# Get current directory where the script is located
script_dir=$(dirname "$0")

# Function to show usage
show_usage() {
    echo "Usage: $0 [--to-router|--from-router]"
    echo "  --to-router    Copy local adguard config to the router"
    echo "  --from-router  Copy adguard config from router to local ignore.d directory"
    exit 1
}

# Check for arguments
if [ $# -eq 0 ]; then
    show_usage
fi

case "$1" in
    --to-router)
        echo "Copying local adguard config to router..."
        if [ ! -f "$script_dir/../ignore.d/adguard-config" ]; then
            echo "Error: Local adguard config file not found at ignore.d/adguard-config"
            exit 1
        fi
        ssh root@192.168.8.1 "cat > /etc/AdGuardHome/config.yaml" < "$script_dir/../ignore.d/adguard-config"
        echo "AdGuard config uploaded to router."
        ;;
    --from-router)
        echo "Copying adguard config from router..."
        mkdir -p "$script_dir/../ignore.d"
        ssh root@192.168.8.1 "cat /etc/AdGuardHome/config.yaml" > "$script_dir/../ignore.d/adguard-config"
        echo "AdGuard config copied to ignore.d/adguard-config"
        ;;
    *)
        echo "Error: Unknown option '$1'"
        show_usage
        ;;
esac
