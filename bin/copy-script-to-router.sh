#!/bin/bash

# Get current directory where the script is located
script_dir=$(dirname "$0")

# Copy the script to the router
ssh root@192.168.8.1 "cat > /etc/gl-switch.d/vpn.sh" < $script_dir/../switch-scripts/mt3000/custom/vpn-custom.sh

# Make the script executable
ssh root@192.168.8.1 "chmod +x /etc/gl-switch.d/vpn.sh"