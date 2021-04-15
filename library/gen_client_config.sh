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
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = ${END_POINT}
EOL
}

# ---------------------------------
# Main
# ---------------------------------

if [ $# -eq 5 ]; then
    # Arguments
    CLIENT_PRIVATE_KEY=$1
    CLIENT_IP=$2
    DNS=$3
    END_POINT=$4
    CLIENT_CONFIG_FILE=$5

    # Generate the server configuration file
    echo "> Generating client config file: ""$CLIENT_CONFIG_FILE"
    generate_client_config
    chmod 600 "$CLIENT_CONFIG_FILE"
else
    echo "Usage: gen_client_config.sh <client_private_key> <client_ip> <dns> <end_point> <client_config_file>"
fi
