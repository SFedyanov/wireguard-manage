#!/bin/bash
#https://github.com/davidgross/wireguard-scripts
#client.example.conf
DEBUG=true


main (){
  printf "${grn}Remove WireGuad peer client${end}\n"
 
  env
  check_parameter $@
  CLIENT_NAME=$1
  remove_peer

  printf "${grn}Done.${end}\n"
}

remove_peer(){
  if [[ $(user_already_exists) = true ]]
  then
    printf "${red}Peer $CLIENT_NAME exist and will be removed!${end}\n\n"
  backup_user_data
  remove_peer_from_wireguard
  remove_user_folder

  else
    printf "${grn}Peer does not exist!${end}\n\n"
  fi
}

backup_user_data(){
BKP_FILE_NAME=${WORK_DIR}/backup/${CLIENT_NAME}-$(date +"%Y-%m-%d_%T").tar.gz
  printf "${blu}Backuping user data...$CLIENTS_DIR/$CLIENT_NAME\n to ${BKP_FILE_NAME}${end}\n"
  mkdir -p ${WORK_DIR}/backup ; tar zcvf ${BKP_FILE_NAME} ${CLIENTS_DIR}/${CLIENT_NAME} 
}

remove_user_folder(){
  printf "${blu}Removing directory: $CLIENTS_DIR/$CLIENT_NAME${end}\n"
  rm -rf $CLIENTS_DIR/$CLIENT_NAME
}

remove_peer_from_wireguard(){
  printf "${blu}Removing peer $CLIENT_NAME fro wireguard...\n"
  wg set $INTERFACE_NAME peer $(cat $CLIENTS_DIR/$CLIENT_NAME/$CLIENT_NAME.pub) remove
}

user_already_exists(){
  [ -d "$CLIENTS_DIR/$CLIENT_NAME" ] && echo true
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

env(){
  env_colors
  SCRIPT_PATH=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
  export $(cat $SCRIPT_PATH/.env | sed 's/#.*//g' | xargs)
  SERVER_PUB_KEY=$(cat $SERVER_PUPLIC_KEY_FILE)
  CLIENTS_DIR=$WORK_DIR/clients
  if [ "$DEBUG" = true ]
  then
    printf "${blu}DEBUG: 
	   WORK_DIR='$WORK_DIR'
	   CLIENTS_DIR='$CLIENTS_DIR'
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
