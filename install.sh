#!/bin/bash

echo "Installing Tor IP Changer V3..."

chmod +x tor-ip-changer.sh

mkdir -p $HOME/.tor-ip-changer

cp tor-ip-changer.sh $HOME/.tor-ip-changer/

echo
echo "Installation complete!"
echo
echo "Run tool using:"
echo "bash ~/.tor-ip-changer/tor-ip-changer.sh"
