#!/bin/bash

# Get current directory where the script is located
script_dir=$(dirname "$0")

# Function to show usage
show_usage() {
    echo "Usage: $0 [--to-router|--from-router]"
    echo "  --to-router    Copy local wireguard config to the router"
    echo "  --from-router  Copy wireguard config from router to local ignore.d directory"
    exit 1
}

# Check for arguments
if [ $# -eq 0 ]; then
    show_usage
fi

case "$1" in
    --to-router)
        echo "Copying local wireguard config to router..."
        if [ ! -f "$script_dir/../ignore.d/wireguard-config" ]; then
            echo "Error: Local wireguard config file not found at ignore.d/wireguard-config"
            exit 1
        fi
        ssh root@192.168.8.1 "cat > /etc/config/wireguard" < "$script_dir/../ignore.d/wireguard-config"
        echo "Wireguard config uploaded to router."
        ;;
    --from-router)
        echo "Copying wireguard config from router..."
        mkdir -p "$script_dir/../ignore.d"
        ssh root@192.168.8.1 "cat /etc/config/wireguard" > "$script_dir/../ignore.d/wireguard-config"
        echo "Wireguard config copied to ignore.d/wireguard-config"
        ;;
    *)
        echo "Error: Unknown option '$1'"
        show_usage
        ;;
esac
