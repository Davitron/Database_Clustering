#!/usr/bin/env bash


set -x

function get_metadata {
  local name="$1"
  curl -s -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/instance/attributes/${name}"
}

# install haproxy on machine
function install_hapoxy {
  sudo add-apt  --assume-yes -repository ppa:vbernat/haproxy-1.8
  sudo apt-get update -y
  sudo apt-get install haproxy -y
}

function configure_haproxy {
  # get value of IP addresses from the haproxy instance metadata
  MASTER_IP=$(get_metadata "master_ip")
  SLAVE1_IP=$(get_metadata "slave1_ip")
  SLAVE2_IP=$(get_metadata "slave2_ip")

  # remove existing haproxy config
  sudo rm -v /etc/haproxy/haproxy.cfg

  # replace IP address placeholders witht he correct IP addresses
  # in the new haproxy config file
  sudo sed -i -e "s|<master_ip>|$MASTER_IP|g" ./haproxy.cfg
  sudo sed -i -e "s|<slave1_ip>|$SLAVE1_IP|g" ./haproxy.cfg
  sudo sed -i -e "s|<slave2_ip>|$SLAVE2_IP|g" ./haproxy.cfg

  # copy the new config to /etc/haproxy/
  sudo cp -v ./haproxy.cfg /etc/haproxy/haproxy.cfg

  # validate the new config
  sudo haproxy -c -f /etc/haproxy/haproxy.cfg

  # restart the service
  sudo service haproxy restart
}

function main {
  install_hapoxy
  configure_haproxy
}

main
