#!/bin/sh

# Combined WireGuard and AdGuardHome control script
# Usage: ./wireguard.sh [on|off]

# WireGuard control
. /lib/functions/gl_util.sh

action=$1

[ "$1" = "on" ] && enabled=1 || enabled=0

tunnel=$(uci -q get switch-button.@main[0].sub_func)

switch_rule() {
    config_get name $1 name
    if [ "$tunnel" != "$name" ];then
        return
    fi

    config_get via_type $1 via_type
    config_get peer_id $1 peer_id
    config_get group_id $1 group_id
    config_get client_id $1 client_id

    [ "$via_type" != "wireguard" ] && [ "$via_type" != "openvpn" ] && return

    [ "$via_type" = "wireguard" ] && [ "$(uci -q get wireguard.peer_$peer_id)" != "peers" ] && return
    [ "$via_type" = "openvpn" ] && [ "$(uci -q get ovpnclient."$group_id"_"$client_id")" != "clients" ] && return

    uci set route_policy.$1.enabled=$enabled
    uci commit route_policy

    /etc/init.d/vpn-client restart&
    sleep 5
}

config_load route_policy

config_foreach switch_rule rule

# Adguardhome control

status=$(uci -q get adguardhome.config.enabled)

if [ "$action" = "on" -a "$status" != "1" ];then
    ubus call gl-session call '{"module":"adguardhome", "func":"set_config", "params": {"enabled": true}}'
fi

if [ "$action" = "off" -a "$status" != "0" ];then
    ubus call gl-session call '{"module":"adguardhome", "func":"set_config", "params": {"enabled": false}}'
fi

sleep 5