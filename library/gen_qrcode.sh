#!/bin/bash
if [ $# -eq 1 ]
  then
    echo "Generate QR code for: $1"
    qrencode -t ansiutf8 -r $1
  else
    echo "Provide a configuration."
    echo "Usage: gen_qr.sh <xxx.conf>"
fi