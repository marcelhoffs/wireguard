#!/bin/bash

# ---------------------------------
# Variables
# ---------------------------------

CLIENT_NAME=''
CLIENT_IP=''

# ---------------------------------
# Functions
# ---------------------------------

init() {
    # Clear the screen
    clear
}

# ---------------------------------

setup_questions() {
    echo ''
    echo -e '╔════════════════════════════════════════╗'
    echo -e '║ WireGuard server configurator          ║'
    echo -e '║ Marcel Hoffs, 13.04.2021               ║'
    echo -e '║ Version 1.0                            ║'
    echo -e '╚════════════════════════════════════════╝'
    echo ''

    # Client name
    while [ "$CLIENT_NAME" == '' ]; do
        read -r -p 'Client name [e.g. laptop] : ' CLIENT_NAME
        CLIENT_NAME=${CLIENT_NAME,,}
    done

    echo ''
}

# ---------------------------------

generate_client_keys() {
    NAME=$1

    # Generate the keypair
    ./library/gen_keypair.sh "$NAME"
    mv "$NAME"_privatekey keys
    mv "$NAME"_publickey keys
}

# ---------------------------------

get_data() {
    NAME=$1

    # Get the server public key from the file
    SERVER_PUBLIC_KEY=$(<keys/server_publickey)

    # Get the client private key from the file
    CLIENT_PRIVATE_KEY=$(<keys/"$NAME"_privatekey)
    CLIENT_PUBLIC_KEY=$(<keys/"$NAME"_publickey)

    # Get server config file
    SERVER_CONFIG_FILE=$(<"config/server_config_file")

    # Get DNS
    DNS=$(<"config/dns")

    # Get End Point
    END_POINT=$(<"config/endpoint")

    # Get last client IP
    CLIENT_IP=$(<"config/last_client_ip")
}

# ---------------------------------

generate_client_config() {
    NAME=$1

    # Determine name of config file
    CLIENT_CONFIG_FILE="$NAME"".conf"
    FULL_CLIENT_CONFIG_FILE="client/""$CLIENT_CONFIG_FILE"
 
    # Generating client config
    ./library/gen_client_config.sh "$CLIENT_PRIVATE_KEY" "$CLIENT_IP" "$DNS" "$END_POINT" "$FULL_CLIENT_CONFIG_FILE"
}

# ---------------------------------

generate_qr_code() {
    NAME=$1

    # Generate QR Code
    echo ""
    ./library/gen_qrcode.sh "$FULL_CLIENT_CONFIG_FILE"
}

# ---------------------------------

determine_ip() {
    # Variables
    j=0

    # Split client IP by dot
    IFS='.' read -ra ADDR <<<$CLIENT_IP
    for i in "${ADDR[@]}"; do
        # Store ip parts in array
        IP_ADDR_ARRAY[j]=$i
        j=$((j + 1))
    done

    # Increase by the last entry in the array by one
    IP_ADDR_ARRAY[3]=$((${IP_ADDR_ARRAY[3]} + 1))

    # Construct the new client ip
    CLIENT_IP="${IP_ADDR_ARRAY[0]}"".""${IP_ADDR_ARRAY[1]}"".""${IP_ADDR_ARRAY[2]}"".""${IP_ADDR_ARRAY[3]}"

    # Write to last_client_ip
    echo "$CLIENT_IP" >config/last_client_ip
}

# ---------------------------------
# Main
# ---------------------------------

init
setup_questions
generate_client_keys "$CLIENT_NAME"
get_data "$CLIENT_NAME"
determine_ip
./library/add_client_to_server.sh "$CLIENT_NAME" "$CLIENT_PUBLIC_KEY" "$CLIENT_IP" "$SERVER_CONFIG_FILE"
generate_client_config "$CLIENT_NAME"
generate_qr_code "$CLIENT_NAME"
