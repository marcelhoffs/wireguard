#!/bin/bash

# ---------------------------------
# Variables
# ---------------------------------

SERVER_IP=''


# ---------------------------------
# Functions
# ---------------------------------

setup_questions()
{
  # Server IP address
  while [ "$SERVER_IP" == '' ]; do
    read -r -p ' 1)  Server IP address [e.g. 10.0.0.1] : ' SERVER_IP
  done
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