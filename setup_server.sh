#!/bin/bash

# ---------------------------------
# Variables
# ---------------------------------

SERVER_CONFIG_FILE='wg0.conf'
SERVER_IP=''
SERVER_PORT=''
SERVER_NETWORK=''
SERVER_PRIVATE_KEY=''

# ---------------------------------
# Functions
# ---------------------------------

init()
{
    # Clear the screen
    clear

    # Make library executable
    chmod -R +x library

    # Create config directory
    mkdir config
    mkdir keys
}

# ---------------------------------

setup_questions()
{
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

  echo ''
}

# ---------------------------------

store_config()
{ 
  # Store config
  echo "Storing configuration in config directory"

  # Store server IP in file
  echo "$SERVER_IP" > config/server_ip
  
  # Store server port in file
  echo "$SERVER_PORT" > config/server_port
  
  # Store network interface
  echo "$SERVER_NETWORK" > config/server_network
  
  # Set permissions
  chmod -R 600 config  
  chmod -R 600 keys
}

# ---------------------------------

generate_server_keys()
{
  # Generate the keypair
  ./library/gen_keypair.sh server
  mv server_privatekey keys
  mv server_publickey keys

  # Get the private key from the file
  SERVER_PRIVATE_KEY=$(<keys/server_privatekey)
}

# ---------------------------------

generate_server_config()
{
  # Generate the server configuration file
  echo "Generating server configuration file: ""$SERVER_CONFIG_FILE" 

  echo "[Interface]" > "$SERVER_CONFIG_FILE"
  echo "Address = ""$SERVER_IP" >> "$SERVER_CONFIG_FILE"
  echo "ListenPort = ""$SERVER_PORT" >> "$SERVER_CONFIG_FILE"
  echo "PrivateKey = ""$SERVER_PRIVATE_KEY" >> "$SERVER_CONFIG_FILE"
  echo "PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ""$SERVER_NETWORK"" -j MASQUERADE" >> "$SERVER_CONFIG_FILE"
  echo "PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ""$SERVER_NETWORK"" -j MASQUERADE" >> "$SERVER_CONFIG_FILE"
}

# ---------------------------------
# Main
# ---------------------------------

init
setup_questions
store_config
generate_server_keys
generate_server_config