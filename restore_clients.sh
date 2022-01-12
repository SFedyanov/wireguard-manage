#!/bin/bash
#https://github.com/davidgross/wireguard-scripts
#client.example.conf
DEBUG=true


main (){
  printf "${grn}Generate WireGuad peer client${end}\n"
 
  env
  restore_clients
#  check_parameter $@
#  CLIENT_NAME=$1
#  create_peer

  printf "${grn}Done.${end}\n"
}

restore_clients() {
  for client in $CLIENTS_DIR/* ; do
    CLIENT_NAME=$(basename $client)
    echo $CLIENT_NAME
    CLIENT_IP=$(get_ip_from_conf $CLIENTS_DIR/$CLIENT_NAME/$CLIENT_NAME.conf)
    wg set $INTERFACE_NAME peer $(cat $CLIENTS_DIR/$CLIENT_NAME/$CLIENT_NAME.pub) allowed-ips $CLIENT_IP
    echo ""
  done
}

get_ip_from_conf(){
  ipline=$(cat $1 | grep Address)
  ip=$(echo $ipline |awk '{print $3}' | cut -f1 -d"/")
  echo $ip
}

env(){
  env_colors
  SCRIPT_PATH=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
  export $(cat $SCRIPT_PATH/.env | sed 's/#.*//g' | xargs)
  SERVER_PUB_KEY=$(cat $SERVER_PUPLIC_KEY_FILE)
  CLIENTS_DIR=$WORK_DIR/clients
  CLIENT_IP=$(generate_ip_address)
  if [ "$DEBUG" = true ]
  then
    printf "${blu}DEBUG: 
	   WORK_DIR='$WORK_DIR'
	   CLIENTS_DIR='$CLIENTS_DIR'
	   CLIENT_IP='$CLIENT_IP'
	   SERVER_PUB_KEY='$SERVER_PUB_KEY'
	   SERVER_ADDRESS='$SERVER_ADDRESS'
	   SERVER_PORT='$SERVER_PORT'
	   SCRIPT_PATH='$SCRIPT_PATH'
	   DNS_IP='$DNS_IP'
	   NETWORK='$NETWORK'
	   INTERFACE_NAME='$INTERFACE_NAME'
           ${end}\n"
  fi
}

env_colors(){
  red=$'\e[1;31m'
  grn=$'\e[1;32m'
  yel=$'\e[1;33m'
  blu=$'\e[1;34m'
  mag=$'\e[1;35m'
  cyn=$'\e[1;36m'
  end=$'\e[0m'
}

main $@
