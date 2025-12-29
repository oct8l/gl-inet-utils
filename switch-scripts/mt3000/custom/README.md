# GL-iNet MT3000 Custom VPN + AdGuard Switch Script

This directory contains a custom script that combines VPN (WireGuard/OpenVPN) control with AdGuard Home management for GL-iNet MT3000 routers, allowing both services to be controlled with a single physical switch flip.

## Overview

The `vpn-custom.sh` script enhances the default GL-iNet switch functionality by:

1. **VPN Control**: Manages WireGuard or OpenVPN connections through the router's route policy system
2. **AdGuard Integration**: Automatically enables/disables AdGuard Home DNS filtering alongside VPN control
3. **Physical Switch Integration**: Works seamlessly with the MT3000's physical switch mechanism

## Script Functionality

### VPN Control (Original GL-iNet Logic)

- Reads the configured VPN tunnel from switch settings (`switch-button.@main[0].sub_func`)
- Manages route policies for WireGuard and OpenVPN connections
- Supports peer-based WireGuard configurations and client-based OpenVPN setups
- Restarts the VPN client service when toggling states

### AdGuard Home Control (Custom Addition)

- Monitors current AdGuard Home status via UCI configuration
- Uses GL-iNet's session API to enable/disable AdGuard Home
- Only toggles AdGuard when necessary (avoids redundant state changes)
- Integrates with the router's native AdGuard Home management system

## Installation Methods

### Method 1: SSH with Local Copy Script (Recommended)

If you have SSH access configured and this repository cloned locally:

```bash
# Clone the repository (if not already done)
git clone https://github.com/oct8l/gl-inet-utils.git
cd gl-inet-utils

# Copy the script to your router
./bin/copy-switch-script.sh --to-router
```

### Method 2: Direct SSH Installation

If you have SSH access but don't want to clone the repository:

```bash
# SSH into your router
ssh root@192.168.8.1

# Download the script directly
curl -o /etc/gl-switch.d/vpn.sh https://raw.githubusercontent.com/oct8l/gl-inet-utils/main/switch-scripts/mt3000/custom/vpn-custom.sh

# Make it executable
chmod +x /etc/gl-switch.d/vpn.sh

# Exit SSH session
exit
```

### Method 3: Using wget (Alternative Download)

If `curl` is not available, you can use `wget`:

```bash
# SSH into your router
ssh root@192.168.8.1

# Download using wget
wget -O /etc/gl-switch.d/vpn.sh https://raw.githubusercontent.com/oct8l/gl-inet-utils/main/switch-scripts/mt3000/custom/vpn-custom.sh

# Make it executable
chmod +x /etc/gl-switch.d/vpn.sh

# Exit SSH session
exit
```

### Method 4: Manual Copy-Paste

If you prefer manual installation:

1. SSH into your router: `ssh root@192.168.8.1`
2. Create/edit the file: `vi /etc/gl-switch.d/vpn.sh`
3. Copy the contents of `vpn-custom.sh` into the editor
4. Save and exit (`:wq` in vi)
5. Make executable: `chmod +x /etc/gl-switch.d/vpn.sh`

## Configuration Requirements

### Switch Configuration

Ensure your router's switch is configured to use the VPN function:

```bash
# Check current switch configuration
uci show switch-button

# If not set to 'vpn', configure it:
uci set switch-button.@main[0].func='vpn'
uci set switch-button.@main[0].sub_func='Your VPN Name'
uci commit switch-button
```

### VPN Setup Prerequisites

Before using this script, ensure you have:

1. **VPN Configuration**: A working WireGuard or OpenVPN configuration
2. **Route Policies**: Proper route policies configured for your VPN
3. **AdGuard Home**: AdGuard Home installed and configured (optional but recommended)

## Usage

### Physical Switch Operation

Once installed, the physical switch on your MT3000 will control both services:

- **Switch ON**: Enables your configured VPN + Turns on AdGuard Home
- **Switch OFF**: Disables VPN + Turns off AdGuard Home

### Manual Testing

You can test the script manually via SSH:

```bash
# Test turning services OFF
/etc/gl-switch.d/vpn.sh off

# Test turning services ON
/etc/gl-switch.d/vpn.sh on

# Check AdGuard status
uci -q get adguardhome.config.enabled
# Returns: 1 (enabled) or 0 (disabled)
```

### Status Monitoring

Monitor the services through various methods:

```bash
# Check AdGuard Home status
uci -q get adguardhome.config.enabled

# Check VPN client status
/etc/init.d/vpn-client status

# View route policies
uci show route_policy

# Check switch configuration
uci show switch-button
```

## Troubleshooting

### Common Issues

1. **Script Not Executing**

   ```bash
   # Check if file exists and is executable
   ls -la /etc/gl-switch.d/vpn.sh

   # Fix permissions if needed
   chmod +x /etc/gl-switch.d/vpn.sh
   ```

2. **AdGuard Not Toggling**

   ```bash
   # Test AdGuard commands manually
   ubus call gl-session call '{"module":"adguardhome", "func":"set_config", "params": {"enabled": true}}'

   # Check if AdGuard Home is installed
   which AdGuardHome
   ```

3. **VPN Not Connecting**

   ```bash
   # Check VPN configuration
   uci show wireguard  # for WireGuard
   uci show ovpnclient # for OpenVPN

   # Check route policies
   uci show route_policy
   ```

4. **Switch Not Working**

   ```bash
   # Verify switch configuration
   uci show switch-button

   # Check switch function is set to 'vpn'
   uci get switch-button.@main[0].func
   ```

### Debug Mode

Enable detailed logging by modifying the script to add debug output:

```bash
# Add at the top of the script after the shebang
set -x  # Enable debug mode

# Or add logging commands
logger -t "vpn-custom" "Script called with action: $1"
```

### Log Monitoring

Monitor system logs for switch-related activity:

```bash
# View recent logs
logread | tail -50

# Filter for switch-related logs
logread | grep -i switch

# Monitor logs in real-time
logread -f
```

## File Structure

```
switch-scripts/mt3000/
├── custom/
│   ├── vpn-custom.sh          # Combined VPN + AdGuard script
│   └── README.md              # This documentation
├── original/
│   ├── vpn.sh                 # Original GL-iNet VPN script
│   ├── wireguard.sh           # Original WireGuard-only script
│   └── adguard.sh             # Original AdGuard-only script
└── bin/
    └── copy-script-to-router.sh # Deployment script
```

## Technical Details

### Script Components

1. **Initialization**

   - Loads GL-iNet utility functions
   - Parses command line arguments (`on`/`off`)
   - Sets enabled flag for route policies

2. **VPN Management**

   - Reads tunnel configuration from switch settings
   - Iterates through route policy rules
   - Matches configured tunnel name with policy rules
   - Updates policy enabled status and commits changes
   - Restarts VPN client service

3. **AdGuard Integration**
   - Checks current AdGuard Home status
   - Calls GL-iNet session API to toggle AdGuard state
   - Only makes changes when state transition is needed

### Dependencies

- **GL-iNet Firmware**: Compatible with MT3000 firmware
- **UCI System**: For configuration management
- **ubus**: For AdGuard Home control
- **Route Policies**: For VPN management
- **GL Utilities**: GL-iNet specific functions

## Security Considerations

- The script runs with root privileges through the switch mechanism
- Ensure SSH access is properly secured if using remote installation methods
- AdGuard configuration changes are logged through the system
- VPN changes affect network routing for all connected devices

## Contributing

To contribute improvements or report issues:

1. Fork the repository: `https://github.com/oct8l/gl-inet-utils`
2. Create a feature branch
3. Test changes on actual MT3000 hardware
4. Submit a pull request with detailed description

## Support

For issues specific to this script:

- Check the troubleshooting section above
- Review GL-iNet community forums
- Examine router logs for error messages

For GL-iNet router issues:

- Consult official GL-iNet documentation
- Visit GL-iNet support forums
- Check firmware compatibility

## License

This script extends GL-iNet's original functionality and should be used in accordance with your router's terms of service and applicable open source licenses.
