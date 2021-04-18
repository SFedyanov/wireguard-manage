# Wireguard manage scripts
Bash scripts for adding and removing wireguard peers. And generatin conf file and QR code.

## Requirenments 
1. Clone this repo
2. Install wirequard
3. Install qrencode
4. Configure wireguard
5. Copy dot.env to .env
6. Change the .env file with your data

[How to install and configure wireguard](https://wiki.fedyanov.com/mediawiki/index.php?title=Wireguard#Client)

## How to use:

> create_client.sh peer_name

> remove_client.sh peer_name

## Features:
1. Add peer
2. Remove peer
3. Backup peer data before removing.
4. Generate QR code file for peer
5. Generate conf file for peer

## .env file
```
#Wireguard manage scripts environment file
WORK_DIR=/etc/wireguard
INTERFACE_NAME=wg0
SERVER_PUPLIC_KEY_FILE=/etc/wireguard/server_public.key
SERVER_ADDRESS='<< server name or IP >>'
SERVER_PORT='<< server port >>'
DNS_IP=10.1.1.1
NETWORK=10.1.1.0
```
- WORK_DIR: wireguard work directory.
- INTERFACE_NAME: wireguard configured ethernet interface.
- SERVER_PUPLIC_KEY_FILE: path to server public key file
- SERVER_ADDRESS: server IP or name.
- SERVER_PORT: server port
- DNS_IP: dns server IP
- NETWORK: Subnet for peers. As example server IP is 10.1.1.1 
Script will check configurations files and get first not used IP. 
10.1.1.2, 10.1.1.3 ... etc.
