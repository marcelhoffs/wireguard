#!/bin/bash

# ---------------------------------
# Variables
# ---------------------------------

SERVER_CONFIG_FILE='wg0.conf'
SERVER_IP=''
SERVER_PORT=''
SERVER_NETWORK=''
DNS=''
END_POINT=''
END_POINT_PORT=''

# ---------------------------------
# Functions
# ---------------------------------

init() {
  # Clear the screen
  clear

  # Make library executable
  chmod -R +x library
  chmod +x add_client.sh

  # Create config directory
  mkdir config
  mkdir client
  mkdir keys
}

# ---------------------------------

setup_questions() {
  echo ''
  echo -e ' ╔════════════════════════════════════════╗'
  echo -e ' ║ WireGuard server configurator          ║'
  echo -e ' ║ Marcel Hoffs, 13.04.2021               ║'
  echo -e ' ║ Version 1.0                            ║'
  echo -e ' ╚════════════════════════════════════════╝'
  echo ''

  # Server IP address
  while [ "$SERVER_IP" == '' ]; do
    read -r -p ' 1)  Server IP address [e.g. 10.0.0.1] : ' SERVER_IP
  done

  # Server Port
  while [ "$SERVER_PORT" == '' ]; do
    read -r -p ' 2)  Listening port [e.g. 51820] : ' SERVER_PORT
  done

  # Network interface
  while [ "$SERVER_NETWORK" == '' ]; do
    read -r -p ' 3)  Network interface [e.g. eth0] : ' SERVER_NETWORK
    SERVER_NETWORK=${SERVER_NETWORK,,}
  done

  # DNS
  while [ "$DNS" == '' ]; do
    read -r -p ' 4)  What DNS to use [e.g. 1.1.1.1] : ' DNS
  done

  # End Point
  while [ "$END_POINT" == '' ]; do
    read -r -p ' 5)  End point [e.g. vpn.example.com, an ip address] : ' END_POINT
    END_POINT=${END_POINT,,}
  done

  # End Point port
  while [ "$END_POINT_PORT" == '' ]; do
    read -r -p ' 6)  End point port [e.g. 4000] : ' END_POINT_PORT
    END_POINT_PORT=${END_POINT_PORT,,}
  done

  echo ''
}

# ---------------------------------

store_config() {
  # Store config
  echo " > Storing configuration in config directory"

  # Store server IP in file
  echo "$SERVER_IP" >config/server_ip

  # Store server IP in file
  echo "$SERVER_IP" >config/last_client_ip

  # Store server port in file
  echo "$SERVER_PORT" >config/server_port

  # Store network interface
  echo "$SERVER_NETWORK" >config/server_network

  # Store server config file
  echo "$SERVER_CONFIG_FILE" >config/server_config_file

  # Store DNS settings
  echo "$DNS" >config/dns

  # Store End Point
  echo "$END_POINT"":""$END_POINT_PORT" >config/endpoint

  # Set permissions
  chmod -R 600 config
  chmod -R 600 keys
}

# ---------------------------------

generate_server_keys() {
  # Generate the keypair
  ./library/gen_keypair.sh server
  mv server_privatekey keys
  mv server_publickey keys

  # Get the private key from the file
  SERVER_PRIVATE_KEY=$(<keys/server_privatekey)
}

# ---------------------------------

generate_server_config() {
  # Generate the server configuration file
  echo " > Generating server configuration file: ""$SERVER_CONFIG_FILE"

  echo "[Interface]" >"$SERVER_CONFIG_FILE"
  echo "Address = ""$SERVER_IP" >>"$SERVER_CONFIG_FILE"
  echo "ListenPort = ""$SERVER_PORT" >>"$SERVER_CONFIG_FILE"
  echo "PrivateKey = ""$SERVER_PRIVATE_KEY" >>"$SERVER_CONFIG_FILE"
  echo "PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ""$SERVER_NETWORK"" -j MASQUERADE" >>"$SERVER_CONFIG_FILE"
  echo "PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ""$SERVER_NETWORK"" -j MASQUERADE" >>"$SERVER_CONFIG_FILE"

  chown 600 "$SERVER_CONFIG_FILE"
}

# ---------------------------------
# Main
# ---------------------------------

init
setup_questions
store_config
generate_server_keys
generate_server_config
echo ''
