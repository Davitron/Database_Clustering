#!/usr/bin/env bash


set -x


# install haproxy on machine
function install_hapoxy {
  sudo apt-get update -y
  sudo apt-get install haproxy -y
}

function configure_haproxy {

  # remove existing haproxy config
  sudo rm -v /etc/haproxy/haproxy.cfg
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
