#!/usr/bin/env bash

set -o errexit
set -o pipefail

function update_postgres_config {
  sudo systemctl stop postgresql
  echo "=================>update network cidr"
  # set postgres to listen to any address and update network cidr
  sudo sed -i -e "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/9.6/main/postgresql.conf
  sudo sed -i -e "s/127.0.0.1\/32/0.0.0.0\/0/" /etc/postgresql/9.6/main/pg_hba.conf

  echo "=================>updating WAL configurations"
  # update WAL configuration
  sudo sed -i -e "s/#wal_level = minimal/wal_level = hot_standby/" /etc/postgresql/9.6/main/postgresql.conf
	sudo sed -i -e "s/#max_wal_senders = 0/max_wal_senders = 5/" /etc/postgresql/9.6/main/postgresql.conf
	sudo sed -i -e "s/#wal_keep_segments = 0/wal_keep_segments = 32/" /etc/postgresql/9.6/main/postgresql.conf
	sudo sed -i -e "s/#hot_standby = off/hot_standby = on/" /etc/postgresql/9.6/main/postgresql.conf
}

function replace_postgres_main_dir {

  echo "=================>Creating new main directory"
  # create new main directory 
  sudo mv /var/lib/postgresql/9.6/main /var/lib/postgresql/9.6/main-bekup
  sudo mkdir /var/lib/postgresql/9.6/main/
  sudo chmod 700 /var/lib/postgresql/9.6/main/
	sudo chown postgres.postgres /var/lib/postgresql/9.6/main/
}


function create_recovery_file {
  echo "=================>setting up recovery file"
  cat << 'EOF' | sudo tee -a /var/lib/postgresql/9.6/main/recovery.conf >> /dev/null
standby_mode = 'on'
primary_conninfo = 'host=10.0.0.2 port=5432 user=replication password=password'
trigger_file = '/var/lib/postgresql/9.6/trigger'
restore_command = 'cp /var/lib/postgresql/9.6/archive/%f "%p"'
EOF
  sudo chmod 600 /var/lib/postgresql/9.6/main/recovery.conf
  sudo chown postgres.postgres /var/lib/postgresql/9.6/main/recovery.conf
}

function configure_slave_to_pull {
  echo "=================>Running data backup"
  source .env
  # run the data backup
  sudo su postgres -c "export PGPASSWORD=$DB_PASSWORD; pg_basebackup -h $MASTER_IP -D /var/lib/postgresql/9.6/main -P -U replication --xlog-method=stream;"
  # get the create recovery file for archiving

  create_recovery_file
  echo "=================>Restarting Postgresql service"
# start and restart postgres server
  sudo systemctl start postgresql
  sudo systemctl restart postgresql

  echo "=================>Startup Complete"
}

function main {
  update_postgres_config
  replace_postgres_main_dir
  configure_slave_to_pull
}

main