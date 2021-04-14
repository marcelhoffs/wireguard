#!/bin/bash

# ---------------------------------
# Variables
# ---------------------------------

CLIENT_NAME=''
CLIENT_IP=''
END_POINT=''
END_POINT_PORT=''

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

  # Client IP address
  while [ "$CLIENT_IP" == '' ]; do
    read -r -p ' 2)  Client IP address : ' CLIENT_IP
    CLIENT_IP=${CLIENT_IP,,}
  done

  # End Point
  while [ "$END_POINT" == '' ]; do
    read -r -p ' 3)  End point [e.g. vpn.example.com, an ip address] : ' END_POINT
    END_POINT=${END_POINT,,}
  done

  # End Point port
  while [ "$END_POINT_PORT" == '' ]; do
    read -r -p ' 4)  End point port [e.g. 4000] : ' END_POINT_PORT
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

get_data()
{
  NAME=$1

  # Get the server public key from the file
  SERVER_PUBLIC_KEY=$(<keys/SERVER_publickey)

  # Get the client private key from the file
  CLIENT_PRIVATE_KEY=$(<keys/"$NAME"_privatekey)
  CLIENT_PUBLIC_KEY=$(<keys/"$NAME"_publickey)

  # Get server config file
  SERVER_CONFIG_FILE=$(<"config/server_config_file")

  # Get dNS
  DNS=$(<"config/dns")
}

# ---------------------------------

update_server_config()
{ 
  NAME=$1
  
  # Update server config file
  echo " > Updating server configuration file: ""$SERVER_CONFIG_FILE" 

  echo "" >> "$SERVER_CONFIG_FILE"
  echo "[Peer]" >> "$SERVER_CONFIG_FILE"
  echo "# ""$NAME" >> "$SERVER_CONFIG_FILE"
  echo "PublicKey = ""$CLIENT_PUBLIC_KEY" >> "$SERVER_CONFIG_FILE"
  echo "AllowedIPs = ""$CLIENT_IP""/32" >> "$SERVER_CONFIG_FILE"
}

# ---------------------------------

generate_client_config()
{
  NAME=$1

  # Generating client config
  CLIENT_CONFIG_FILE="$NAME"".conf"
  FULL_CLIENT_CONFIG_FILE="client/""$CLIENT_CONFIG_FILE"
  echo " > Generating client config file: config/""$CLIENT_CONFIG_FILE" 
  
  echo "[Interface]" > "$FULL_CLIENT_CONFIG_FILE"
  echo "PrivateKey = ""$CLIENT_PRIVATE_KEY" >> "$FULL_CLIENT_CONFIG_FILE"
  echo "Address = ""$CLIENT_IP""/32" >> "$FULL_CLIENT_CONFIG_FILE"
  echo "DNS = ""$DNS" >> "$FULL_CLIENT_CONFIG_FILE"
  echo "" >> "$FULL_CLIENT_CONFIG_FILE"
  echo "[Peer]" >> "$FULL_CLIENT_CONFIG_FILE"
  echo "AllowedIPs = 0.0.0.0/0, ::/0" >> "$FULL_CLIENT_CONFIG_FILE"
  echo "Endpoint = ""$END_POINT"":""$END_POINT_PORT" >> "$FULL_CLIENT_CONFIG_FILE"

  chmod 600 "$FULL_CLIENT_CONFIG_FILE"
}

# ---------------------------------
generate_qr_code()
{
  NAME=$1    

  # Generate QR Code
  echo ""
  ./library/gen_qrcode.sh "$FULL_CLIENT_CONFIG_FILE"
}

# ---------------------------------
# Main
# ---------------------------------

init
setup_questions
generate_client_keys "$CLIENT_NAME"
get_data "$CLIENT_NAME"
update_server_config "$CLIENT_NAME"
generate_client_config "$CLIENT_NAME"
generate_qr_code "$CLIENT_NAME"