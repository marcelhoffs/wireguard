#!/bin/bash

# ---------------------------------
# Functions
# ---------------------------------

update_server_config() {
    cat >>"$SERVER_CONFIG_FILE" <<EOL

[Peer]
# ${CLIENT_NAME}
PublicKey = ${CLIENT_PUBLIC_KEY}
AllowedIPs = ${CLIENT_IP}/32
EOL
}

# ---------------------------------

restart_service() {
  # Get DNS
  INTERFACE=$(<"config/interface")
  
  # Restart the WireGuard service
  systemctl restart wg-quick@"$INTERFACE" 
}

# ---------------------------------
# Main
# ---------------------------------

if [ $# -eq 4 ]; then
    # Arguments
    CLIENT_NAME=$1
    CLIENT_PUBLIC_KEY=$2
    CLIENT_IP=$3
    SERVER_CONFIG_FILE=$4

    # Generate the server configuration file
    echo "> Updating server configuration file: ""$SERVER_CONFIG_FILE"
    update_server_config
    restart_service
else
    echo "Usage: add_client_to_server.sh <client_name> <client_public_key> <client_ip> <server_config_file>"
fi
