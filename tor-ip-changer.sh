#!/bin/bash

# ==========================================
# TOR IP CHANGER V3 - ULTIMATE EDITION
# ==========================================

VERSION="3.0"

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
WHITE="\e[97m"
RESET="\e[0m"

TOR_PORT="9050"

# ===============================
# Banner
# ===============================
banner(){
clear
echo -e "$CYAN"
echo "╔══════════════════════════════════╗"
echo "        TOR IP CHANGER V3"
echo "        Ultimate Edition"
echo "╚══════════════════════════════════╝"
echo -e "$RESET"
echo "Version : $VERSION"
echo
}

# ===============================
# Check OS
# ===============================
detect_os(){

if command -v pkg &> /dev/null
then
PKG="pkg"
elif command -v apt &> /dev/null
then
PKG="apt"
elif command -v pacman &> /dev/null
then
PKG="pacman"
else
echo "Unsupported system"
exit
fi

}

# ===============================
# Install dependencies
# ===============================
install_deps(){

echo -e "$CYAN[+] Installing dependencies...$RESET"

case $PKG in

pkg)
pkg update -y
pkg install tor curl jq -y
;;

apt)
sudo apt update
sudo apt install tor curl jq -y
;;

pacman)
sudo pacman -Sy tor curl jq
;;

esac

}

# ===============================
# Start TOR
# ===============================
start_tor(){

if pgrep tor > /dev/null
then
echo -e "$GREEN[✓] Tor already running$RESET"
else
echo -e "$YELLOW[•] Starting Tor...$RESET"
tor &> /dev/null &
sleep 8
fi

}

# ===============================
# New Identity
# ===============================
new_ip(){

echo -e "$CYAN[•] Requesting new Tor circuit...$RESET"
pkill -HUP tor
sleep 5

}

# ===============================
# IP Info
# ===============================
ip_info(){

DATA=$(curl -s --socks5 127.0.0.1:$TOR_PORT https://ipinfo.io/json)

IP=$(echo $DATA | jq -r '.ip')
CITY=$(echo $DATA | jq -r '.city')
COUNTRY=$(echo $DATA | jq -r '.country')
ORG=$(echo $DATA | jq -r '.org')

echo
echo -e "$GREEN IP      : $WHITE $IP"
echo -e "$GREEN City    : $WHITE $CITY"
echo -e "$GREEN Country : $WHITE $COUNTRY"
echo -e "$GREEN ISP     : $WHITE $ORG"
echo
}

# ===============================
# Leak Check
# ===============================
leak_check(){

echo -e "$CYAN Checking IP leak...$RESET"

REAL=$(curl -s https://api.ipify.org)
TORIP=$(curl -s --socks5 127.0.0.1:9050 https://api.ipify.org)

if [ "$REAL" != "$TORIP" ]
then
echo -e "$GREEN Tor is working correctly$RESET"
else
echo -e "$RED WARNING: Possible IP leak!$RESET"
fi

}

# ===============================
# Auto Rotate
# ===============================
auto_rotate(){

read -p "Interval seconds (default 15): " T
T=${T:-15}

while true
do

banner
ip_info
echo -e "$CYAN Next IP change in $T seconds$RESET"

sleep $T

new_ip

done

}

# ===============================
# Menu
# ===============================
menu(){

while true
do

banner

echo "1. Start Auto IP Rotation"
echo "2. Show Current IP"
echo "3. Check IP Leak"
echo "4. Restart Tor"
echo "5. Install Dependencies"
echo "0. Exit"

echo
read -p "Select option: " opt

case $opt in

1)
start_tor
auto_rotate
;;

2)
start_tor
banner
ip_info
read -p "Press enter..."
;;

3)
start_tor
leak_check
read -p "Press enter..."
;;

4)
pkill tor
start_tor
;;

5)
install_deps
;;

0)
exit
;;

*)
echo "Invalid option"
sleep 2
;;

esac

done

}

detect_os
menu
