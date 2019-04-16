#! /usr/bin/env bash

function install_postgres {
  echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' | sudo tee -a /etc/apt/sources.list.d/postgresql.list
  wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
  sudo apt-get update
  sudo apt-get install -y postgresql-9.6
}


function main {
  install_postgres
}

main

