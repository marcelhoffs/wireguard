#!/bin/bash
if [ $# -eq 5 ]; then
    # Arguments
    SERVER_CONFIG_FILE=$5
    SERVER_IP=$1
    SERVER_PORT=$2
    SERVER_PRIVATE_KEY=$3
    SERVER_NETWORK=$4

    # Generate the server configuration file
    echo " > Generating server configuration file: ""$SERVER_CONFIG_FILE"

    echo "[Interface]" >"$SERVER_CONFIG_FILE"
    echo "Address = ""$SERVER_IP" >>"$SERVER_CONFIG_FILE"
    echo "ListenPort = ""$SERVER_PORT" >>"$SERVER_CONFIG_FILE"
    echo "PrivateKey = ""$SERVER_PRIVATE_KEY" >>"$SERVER_CONFIG_FILE"
    echo "PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ""$SERVER_NETWORK"" -j MASQUERADE" >>"$SERVER_CONFIG_FILE"
    echo "PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ""$SERVER_NETWORK"" -j MASQUERADE" >>"$SERVER_CONFIG_FILE"

    chown 600 "$SERVER_CONFIG_FILE"
else
    echo "Provide all arguments"
    echo "Usage: gen_serverconfig.sh <server_ip> <server_port> <server_privatekey> <server_network> <server_config_file>"
fi
