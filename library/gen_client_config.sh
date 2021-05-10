#!/bin/bash

# ---------------------------------
# Functions
# ---------------------------------

generate_client_config() {
    cat >>"$CLIENT_CONFIG_FILE" <<EOL

[Interface]
PrivateKey = ${CLIENT_PRIVATE_KEY}
Address = ${CLIENT_IP}/32
DNS = ${DNS}

[Peer]
PublicKey = ${SERVER_PUBLIC_KEY}
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = ${END_POINT}
EOL
}

# ---------------------------------
# Main
# ---------------------------------

if [ $# -eq 6 ]; then
    # Arguments
    SERVER_PUBLIC_KEY=$1
    CLIENT_PRIVATE_KEY=$2
    CLIENT_IP=$3
    DNS=$4
    END_POINT=$5
    CLIENT_CONFIG_FILE=$6

    # Generate the server configuration file
    echo "> Generating client config file: ""$CLIENT_CONFIG_FILE"
    generate_client_config
    chmod 600 "$CLIENT_CONFIG_FILE"
else
    echo "Usage: gen_client_config.sh <server_public_key> <client_private_key> <client_ip> <dns> <end_point> <client_config_file>"
fi
