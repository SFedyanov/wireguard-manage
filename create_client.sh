#!/bin/bash
#https://github.com/davidgross/wireguard-scripts
#client.example.conf
DEBUG=true


main (){
  printf "${grn}Generate WireGuad peer client${end}\n"

  env
  check_parameter $@
  CLIENT_NAME=$1
  create_peer

  printf "${grn}Done.${end}\n"
}

create_peer(){
  if [[ $(user_already_exists) = true ]]
  then
    printf "${red}Peer alredy exist!${end}\n\n"

  else
    printf "${grn}Creating peer...${end}\n\n"
    create_user_folder
    generate_user_keys
    create_conf_file
    generate_qrcode_file
    add_user_to_wireguard
  fi
  print_user_info
}

create_user_folder(){
  printf "${blu}Creating directory: $CLIENTS_DIR/$CLIENT_NAME${end}\n"
  mkdir -p $CLIENTS_DIR/$CLIENT_NAME
}

add_user_to_wireguard(){
  printf "${blu}Adding peer $CLIENT_NAME to wireguard...\n"
  wg set $INTERFACE_NAME peer $(cat $CLIENTS_DIR/$CLIENT_NAME/$CLIENT_NAME.pub) allowed-ips $CLIENT_IP
#  wg set wg0 peer 0Uppb3JF61vw2xgLFRAPKWMcEy0jkvY9OshuWInXkEg= remove
}

print_user_info(){
  printf "${blu}User files in the directory: $CLIENTS_DIR/$CLIENT_NAME \n"
  find $CLIENTS_DIR/$CLIENT_NAME/*
  printf "\n${blu}Configuration:${end}\n"
  cat $CLIENTS_DIR/$CLIENT_NAME/$CLIENT_NAME.conf
  printf "\n${blu}QR code:${end}\n"
  qrencode -t ansiutf8 < $CLIENTS_DIR/$CLIENT_NAME/$CLIENT_NAME.conf
}

generate_qrcode_file(){
  qrencode -o $CLIENTS_DIR/$CLIENT_NAME/$CLIENT_NAME.png  -t PNG < $CLIENTS_DIR/$CLIENT_NAME/$CLIENT_NAME.conf
}

user_already_exists(){
  [ -d "$CLIENTS_DIR/$CLIENT_NAME" ] && echo true
}

generate_user_keys(){
  printf "${blu}Generating keys...${end}\n"
  wg genkey | tee $CLIENTS_DIR/$CLIENT_NAME/$CLIENT_NAME.key | wg pubkey > $CLIENTS_DIR/$CLIENT_NAME/$CLIENT_NAME.pub
  CLIENT_PRIVATE_KEY=$(cat $CLIENTS_DIR/$CLIENT_NAME/$CLIENT_NAME.key)
  CLIENT_PUBLIC_KEY=$(cat $CLIENTS_DIR/$CLIENT_NAME/$CLIENT_NAME.pub)
}

create_conf_file(){
  printf "${blu}Generating conf file...${end}\n"
  cat $SCRIPT_PATH/client.example.conf | sed -e 's|:CLIENT_IP:|'"$CLIENT_IP"'|' | sed -e 's|:CLIENT_KEY:|'"$CLIENT_PRIVATE_KEY"'|' | sed -e 's|:SERVER_PUB_KEY:|'"$SERVER_PUB_KEY"'|' | sed -e 's|:SERVER_ADDRESS:|'"$SERVER_ADDRESS"'|' | sed -e 's|:SERVER_PORT:|'"$SERVER_PORT"'|' | sed -e 's|:DNS_IP:|'"$DNS_IP"'|' > $CLIENTS_DIR/$CLIENT_NAME/$CLIENT_NAME.conf
}

check_parameter(){
  if (( $# != 1 )); then
    print_usage
  exit
fi
}

print_usage(){
  printf "${red}Usage: $0 <Client_name>.\n${yel}Example: $0 sfedyanov\n${end}"
}

generate_ip_address(){
for ip in $(nmap -sL -n ${NETWORK}/24 | awk '/Nmap scan report/{print $NF}' | tail -n +3)
do
  if [[ $(ip_already_used $ip) = false ]]
  then
    echo $ip
    return  # $ip
  fi
done
}

ip_already_used(){
  grep -qinr --include \*.conf "${1}\/32" $WORK_DIR
  if [ $? -eq 0 ] ; then echo true ; else echo false ; fi
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
