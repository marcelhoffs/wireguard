#!/bin/bash

# ---------------------------------
# Variables
# ---------------------------------

SERVER_PUBLIC_KEY=''
CLIENT_PRIVATE_KEY=''

# ---------------------------------
# Functions
# ---------------------------------

init()
{
    # Clear the screen
    clear
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

  # Client name
  while [ "$CLIENT_NAME" == '' ]; do
    read -r -p ' 1)  Client name [e.g. THINKPAD] : ' CLIENT_NAME
    CLIENT_NAME=${CLIENT_NAME^^}
  done

  # End Point
  while [ "$END_POINT" == '' ]; do
    read -r -p ' 2)  End point [e.g. vpn.example.com, an ip address] : ' END_POINT
    END_POINT=${END_POINT,,}
  done

  # End Point port
  while [ "$END_POINT_PORT" == '' ]; do
    read -r -p ' 3)  End point port [e.g. 4000] : ' END_POINT_PORT
    END_POINT_PORT=${END_POINT_PORT,,}
  done

  echo ''
}

# ---------------------------------

generate_client_keys()
{
  NAME=$1

  # Generate the keypair
  ./library/gen_keypair.sh "$NAME"
  mv "$NAME"_privatekey keys
  mv "$NAME"_publickey keys  
}

# ---------------------------------

get_keys()
{
  NAME=$1

  # Get the server public key from the file
  SERVER_PUBLIC_KEY=$(<keys/server_publickey)

  # Get the client private key from the file
  SERVER_PUBLIC_KEY=$(<keys/"$NAME"_privatekey)
}

# ---------------------------------
# Main
# ---------------------------------

init
setup_questions
generate_client_keys "$CLIENT_NAME"
get_keys "$CLIENT_NAME"
#generate_client_config
#update_server_config
echo ''