#!/usr/bin/env bash


function get_metadata {
  local name="$1"
  curl -s -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/instance/attributes/${name}"
}

function update_postgres_config {
  # set postgres to listen to any address and update network cidr
  sudo sed -i -e "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/9.6/main/postgresql.conf
  sudo sed -i -e "s/127.0.0.1\/32/10.0.0.0\/24/" /etc/postgresql/9.6/main/pg_hba.conf

  # update WAL configuration
  sudo sed -i -e "s/#wal_level = minimal/wal_level = hot_standby/" /etc/postgresql/9.6/main/postgresql.conf
	sudo sed -i -e "s/#max_wal_senders = 0/max_wal_senders = 2/" /etc/postgresql/9.6/main/postgresql.conf
	sudo sed -i -e "s/#wal_keep_segments = 0/wal_keep_segments = 10/" /etc/postgresql/9.6/main/postgresql.conf
	sudo sed -i -e "s/#hot_standby = off/hot_standby = on/" /etc/postgresql/9.6/main/postgresql.conf
  # restart postgres service 
  sudo systemctl restart postgresql
}

function replace_postgres_main_dir {
  sudo systemctl stop postgresql
  # create ne main directory 
  sudo mv /var/lib/postgresql/9.6/main /var/lib/postgresql/9.6/main-bekup
  sudo mkdir /var/lib/postgresql/9.6/main/
  sudo chmod 700 /var/lib/postgresql/9.6/main/
	sudo chown postgres.postgres /var/lib/postgresql/9.6/main/
}

function configure_slave_to_pull {
  # get value of IP addresses from the haproxy instance metadata
  MASTER_IP=$(get_metadata "master_ip")
  DB_PASSWORD=$(get_metadata "db_password")

  # run the data backup
  sudo su postgres -c "export PGPASSWORD=$DB_PASSWORD; pg_basebackup -h $MASTER_IP -D /var/lib/postgresql/9.6/main -P -U replication --xlog-method=stream;"
  sudo sed -i -e "s/#hot_standby = off/hot_standby = on/" /etc/postgresql/9.6/main/postgresql.conf

  # get the create recovery file for archiving
  cat << 'EOF' | sudo tee -a /var/lib/postgresql/9.6/main/recovery.conf >> /dev/null
standby_mode = 'on'
primary_conninfo = 'host=$(MASTER_IP) port=5432 user=replication password=$(DB_PASSWORD)'
trigger_file = '/var/lib/postgresql/9.6/trigger'
restore_command = 'cp /var/lib/postgresql/9.6/archive/%f "%p"'
EOF

# start and restart postgres server
  sudo systemctl start postgresql
  sudo systemctl restart postgresql
}

function main {
  update_postgres_config
  replace_postgres_main_dir
  configure_slave_to_pull
}

main