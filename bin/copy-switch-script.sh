#!/bin/bash

# Get current directory where the script is located
script_dir=$(dirname "$0")

# Function to show usage
show_usage() {
    echo "Usage: $0 [--to-router|--from-router]"
    echo "  --to-router    Copy custom VPN script to the router"
    echo "  --from-router  Copy switch scripts from router to original/ folder"
    exit 1
}

# Check for arguments
if [ $# -eq 0 ]; then
    show_usage
fi

case "$1" in
    --to-router)
        echo "Copying custom VPN script to router..."
        ssh root@192.168.8.1 "cat > /etc/gl-switch.d/vpn.sh" < "$script_dir/../switch-scripts/mt3000/custom/vpn-custom.sh"
        ssh root@192.168.8.1 "chmod +x /etc/gl-switch.d/vpn.sh"
        echo "Custom VPN script copied and made executable on router."
        ;;
    --from-router)
        echo "Copying switch scripts from router to original/ folder..."
        original_dir="$script_dir/../switch-scripts/mt3000/original"

        echo "  Copying adguard.sh..."
        ssh root@192.168.8.1 "cat /etc/gl-switch.d/adguardhome.sh" > "$original_dir/adguardhome.sh"

        echo "  Copying vpn.sh..."
        ssh root@192.168.8.1 "cat /etc/gl-switch.d/vpn.sh" > "$original_dir/vpn.sh"

        echo "  Copying wireguard.sh..."
        ssh root@192.168.8.1 "cat /etc/gl-switch.d/wireguard.sh" > "$original_dir/wireguard.sh"

        echo "All switch scripts copied to original/ folder."
        ;;
    *)
        echo "Error: Unknown option '$1'"
        show_usage
        ;;
esac