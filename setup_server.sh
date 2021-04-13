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
    # Make library executable
    chmod -R +x library

    # Create config directory
    mkdir config
    mkdir keys
}

# ---------------------------------

setup_questions()
{
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
}

# ---------------------------------

store_config()
{ 
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

copy_template()
{
  cp templates/template_server .
  mv template_server "$SERVER_CONFIG_FILE"
  chmod 600 "$SERVER_CONFIG_FILE"
}

# ---------------------------------

replace_template_vars()
{
  sed -i -e "s/<server_ip>/$SERVER_IP/" "$SERVER_CONFIG_FILE"
  sed -i -e "s/<server_port>/$SERVER_PORT/" "$SERVER_CONFIG_FILE"
  sed -i -e "s/<server_network>/$SERVER_NETWORK/" "$SERVER_CONFIG_FILE"
  sed -i -e "s/<server_private_key>/$SERVER_PRIVATE_KEY/" "$SERVER_CONFIG_FILE"
}

# ---------------------------------
# Main
# ---------------------------------

init
setup_questions
store_config
generate_server_keys
copy_template
replace_template_vars