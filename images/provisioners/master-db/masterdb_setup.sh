#!/usr/bin/env bash


set -o errexit
set -o pipefail

function update_postgres_config {
  # set postgres to listen to any address and update network cidr
  sudo sed -i -e "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/9.6/main/postgresql.conf
  sudo sed -i -e "s/127.0.0.1\/32/10.0.0.0\/24/" /etc/postgresql/9.6/main/pg_hba.conf
  # restart postgres service 
  sudo systemctl restart postgresql
}

function configure_replication_role {
  # create replication user
  sudo su postgres -c "psql -c \"CREATE ROLE replication WITH REPLICATION PASSWORD 'password' LOGIN;\"; exit"

  # stop postgres service
  sudo systemctl stop postgresql

  # update WAL configuration in the postgresql.conf file
  sudo sed -i -e "s/#wal_level = minimal/wal_level = hot_standby/" /etc/postgresql/9.6/main/postgresql.conf
  sudo sed -i -e "s/#max_wal_senders = 0/max_wal_senders = 2/" /etc/postgresql/9.6/main/postgresql.conf
  sudo sed -i -e "s/#wal_keep_segments = 0/wal_keep_segments = 10/" /etc/postgresql/9.6/main/postgresql.conf

  # turn archive mode on
  sudo sed -i -e "s/#archive_mode = off/archive_mode = on/" /etc/postgresql/9.6/main/postgresql.conf
  sudo sed -i -e "s/#archive_command = ''/archive_command = 'cp %p \/var\/lib\/postgresql\/9.6\/archive\/%f'/" /etc/postgresql/9.6/main/postgresql.conf

  # create archive directory
  sudo mkdir /var/lib/postgresql/9.6/archive
  sudo chown postgres.postgres /var/lib/postgresql/9.6/archive/
}

function register_replication_user {
  # allow replication user
  sudo sed -i -e "$a host     replication     replication         0.0.0.0/0                    trust" /etc/postgresql/9.6/main/pg_hba.conf

  # start and restart service
  sudo systemctl start postgresql
  sudo systemctl restart postgresql
}

function main {
  update_postgres_config
  configure_replication_role
  register_replication_user
}

main