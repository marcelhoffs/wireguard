#!/bin/bash

# ---------------------------------
# Variables
# ---------------------------------

SERVER_IP=''
SERVER_PORT=''
SERVER_NETWORK=''

# ---------------------------------
# Functions
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

store_config()
{
  # Store server IP in file
  echo "$SERVER_IP" > config/server_ip
  chmod 600 config/server_ip

  # Store server port in file
  echo "$SERVER_PORT" > config/server_port
  chmod 600 config/server_port

  # Store network interface
  echo "$SERVER_NETWORK" > config/server_network
  chmod 600 config/server_network
}

copy_template()
{
  cp templates/template_server .
  mv template_server wg0.conf
  chmod 600 wg0.conf
}

replace_template_vars()
{
  SERVER_IP=''
}

# ---------------------------------
# Main
# ---------------------------------

setup_questions
copy_template
replace_template_vars