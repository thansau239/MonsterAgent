#!/bin/bash
#
# Copyright Somma, Inc All Rights Reserved
#
# License : MIT
# Reference :
#   https://github.com/Cyb3rWard0g/HELK/blob/master/helk_install.sh
#   https://github.com/hyperledger/fabric-samples/blob/release-1.1/first-network/byfn.sh
#   

# Check if user is root
if [[ $EUID -ne 0 ]]; then
  echo "[INFO] You must be root to run this script!!"
  exit 1
fi

LOGFILE="./monster-install.log"

echoerror() {
  printf "${RC} * ERROR${EC}: $@\n" 1>&2;
}

# Check system kernel name
kernel_name="$(uname -s)"

function print_help() {
  echo "Usage: "
  echo "  monster.sh up|down|restart|install"
  echo "  monster.sh -h|--help(print this message)"
  echo "      <mode> - one of 'install', 'up', 'restart' or 'down'"
  echo 
}

# Ask user for confirmation to proceed
function ask_proceed() {
  read -p "Continue? [Y/n]" ans
  case "$ans" in
    y|Y|"" )
      echo "proceeding ..."
    ;;
    n|N )
      echo "exiting..."
      exit 1
    ;;
    * )
      echo "invalid response"
      ask_proceed
    ;;
  esac
}

# Obtaining current host ip
function get_host_ip() {
  echo "[INFO] Obtaining current host IP.."
  case "${kernel_name}" in
    Linux*)   host_ip=$(ip route get 1 | awk '{print $NF;exit}');;
    Darwin*)  host_ip=$(ifconfig en0 | grep inet | grep -v inet6 | cut -d ' ' -f2);;
    *)        host_ip="UNKNOWN:${unameOut}"
  esac
}

# Install Curl
function install_curl() {
  echo "[INFO] Checking if curl is installed first"
  if [ -x "$(command -v curl)" ]; then
    echo "[INFO] curl is already installed" 
  else
    echo "[INFO] curl is not installed"
    echo "[INFO] Installing curl before installing docker.."
    apt-get install -y curl >> $LOGFILE 2>&1
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
      echoerror "Could not install curl (Error Code: $ERROR)."
      exit 1
    fi
  fi
}

# Install Docker
function install_docker() {
  echo "[INFO] Installing docker via convenience script.."
  curl -fsSL get.docker.com -o get-docker.sh >> $LOGFILE 2>&1
  chmod +x get-docker.sh >> $LOGFILE 2>&1
  ./get-docker.sh >> $LOGFILE 2>&1
  ERROR=$?
  if [ $ERROR -ne 0 ]; then
    echoerror "Could not install docker via convenience script (Error Code: $ERROR)."
    if [ -x "$(command -v snap)" ]; then
        SNAP_VERSION=$(snap version | grep -w 'snap' | awk '{print $2}')
        echo "[INFO] Snap v$SNAP_VERSION is available. Trying to install docker via snap.."
        snap install docker >> $LOGFILE 2>&1
        ERROR=$?
        if [ $ERROR -ne 0 ]; then
            echoerror "Could not install docker via snap (Error Code: $ERROR)."
            exit 1
        fi
        echo "[INFO] Docker successfully installed via snap."            
    else
        echo "[INFO] Docker could not be installed. Check monster-install.log for details."
        exit 1
    fi
  fi
}

# Install Docker-Compose
function install_docker_compose() {
  echo "[INFO] Installing docker-compose.."
  curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose >> $LOGFILE 2>&1
  chmod +x /usr/local/bin/docker-compose >> $LOGFILE 2>&1
  ERROR=$?
  if [ $ERROR -ne 0 ]; then
      echoerror "Could not install docker-compose (Error Code: $ERROR)."
      exit 1
  fi
}

# Install Pre Requirements
function install_pre_requirements() {
  #echo "[INFO] Monster IP set to ${host_ip}"
  if [ "$kernel_name" == "Linux" ]; then
    # Reference: https://get.docker.com/
    echo "[INFO] Checking distribution list and version"
    # Check distribution list
    lsb_dist="$(. /etc/os-release && echo "$ID")"
    lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"

    # Check distribution version
    case "$lsb_dist" in
      ubuntu)
          if [ -x "$(command -v lsb_release)" ]; then
            dist_version="$(lsb_release --codename | cut -f2)"
          fi
          if [ -z "$dist_version" ] && [ -r /etc/lsb-release ]; then
            dist_version="$(. /etc/lsb-release && echo "$DISTRIB_CODENAME")"
          fi
      ;;
      debian|raspbian)
          dist_version="$(sed 's/\/.*//' /etc/debian_version | sed 's/\..*//')"
          case "$dist_version" in
            9)
                dist_version="stretch"
            ;;
            8)
                dist_version="jessie"
            ;;
            7)
                dist_version="wheezy"
            ;;
          esac
      ;;
      centos)
          if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
              dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
          fi
      ;;
      rhel|ol|sles)
          ee_notice "$lsb_dist"
          exit 1
          ;;
      *)
          if [ -x "$(command -v lsb_release)"]; then
              dist_version="$(lsb_release --release | cut -f2)"
          fi
          if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
              dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
          fi
      ;;
    esac
    echo "[INFO] You're using $lsb_dist version $dist_version"
    ERROR=$?
    if [ $ERROR -ne 0 ]; then
      echoerror "Could not verify distribution or version of the OS (Error Code: $ERROR)."
    fi

    # Check if docker is installed
    if [ -x "$(command -v docker)" ]; then
      echo "[INFO] Docker already installed"
    else
      echo "[INFO] Docker is not installed"
      # Install Curl if it is not installed
      install_curl
      # Install Docker if it is not installed
      install_docker
    fi
    
    # Check if docker-compose is installed
    if [ -x "$(command -v docker-compose)" ]; then
      echo "[INFO] Docker-compose already installed"
    else
      echo "[INFO] Docker-compose is not installed"
      # Install Curl if it is not installed
      install_curl
      # Installing Docker-Compose
      install_docker_compose
    fi
  else
    # Check if docker is installed
    if [ -x "$(command -v docker)" ] && [ -x "$(command -v docker-compose)" ]; then
      echo "[INFO] Docker & Docker-compose already installed"
    else
      echo "[EROR] Install Docker & Docker-compose for $kernel_name"
      exit
    fi
  fi

  echo "[INFO] Dockerizing Monster-ELK.."
  echo "[INFO] Checking local vm.max_map_count variable and setting it to 262144"
  MAX_MAP_COUNT=262144
  if [ -n "$MAX_MAP_COUNT" -a -f /proc/sys/vm/max_map_count ]; then
      sysctl -q -w vm.max_map_count=$MAX_MAP_COUNT >> $LOGFILE 2>&1
      ERROR=$?
      if [ $ERROR -ne 0 ]; then
          echoerror "Could not set vm.max_map_count to 262144 (Error Code: $ERROR)."
      fi
  fi
}

function install_monster_elk_and_start() {
  echo "[INFO] Building Monster ELK via docker-compose"

  # Building Monster ELK 
  docker-compose up --build -d >> $LOGFILE 2>&1
  ERROR=$?
  if [ $ERROR -ne 0 ]; then
      echoerror "Could not run Monster ELK via docker-compose (Error Code: $ERROR)."
      exit 1
  fi
}

function monster_elk_manual_install() {
  get_host_ip
  install_pre_requirements
  echo "[INFO] Starting the monster-ELK. Please wait."
  install_monster_elk_and_start
  sleep 90
  show_final_information
}

function monster_elk_up {
  echo "[INFO] Start Monster ELK via docker-compose"

  # Building Monster ELK 
  docker-compose up -d >> $LOGFILE 2>&1
  ERROR=$?
  if [ $ERROR -ne 0 ]; then
      echoerror "Could not run Monster ELK via docker-compose (Error Code: $ERROR)."
      exit 1
  fi
}

function monster_elk_down {
  echo "[INFO] Stop Monster ELK via docker-compose"
  # Building Monster ELK 
  docker-compose down >> $LOGFILE 2>&1
  ERROR=$?
  if [ $ERROR -ne 0 ]; then
      echoerror "Could not stop Monster ELK via docker-compose (Error Code: $ERROR)."
      exit 1
  fi
}

function monster_elk_start() {
  get_host_ip
  echo "[INFO] Starting the monster-ELK. Please wait."
  monster_elk_up
  sleep 90
  show_final_information
}

function monster_elk_restart() {
  get_host_ip
  monster_elk_down
  echo "[INFO] Starting the monster-ELK. Please wait."
  monster_elk_up
  sleep 90
  show_final_information 
}

show_final_information(){
    echo " "
    echo " "
    echo "***********************************************************************************"
    echo "** [INFO] USE THE FOLLOWING SETTINGS TO INTERACT WITH THE MONSTER-ELK **"
    echo "***********************************************************************************"
    echo " "
    echo "KIBANA URL: http://${host_ip}"
    echo "LOGSTASH IP: "${host_ip}""
    echo "LOGSTASH PORT: 5000"
    echo " "
    echo "IT IS HUNTING SEASON!!!!!"
    echo " "
    echo " "
    echo " "
}

# Parse commandline args
MODE="$1"

if [ "${MODE}" == "install" ]; then
  monster_elk_manual_install
elif [ "${MODE}" == "up" ]; then
  monster_elk_start
elif [ "${MODE}" == "down" ]; then
  monster_elk_down
elif [ "${MODE}" == "restart" ]; then
  monster_elk_restart
else
  print_help
  exit 1
fi