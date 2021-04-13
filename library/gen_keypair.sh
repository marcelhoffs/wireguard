#!/bin/bash
if [ $# -eq 1 ]
  then
    echo "Generate key pair for: $1"
    wg genkey | tee $1_privatekey | wg pubkey > $1_publickey
    chmod 600 $1_privatekey
    chmod 644 $1_publickey
  else
    echo "Provide a device name"
    echo "Usage: gen_keypair.sh <device name>"
fi