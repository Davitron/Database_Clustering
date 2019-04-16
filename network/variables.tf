variable "public_subnet_cidr" {
  default = ""
}
variable "private_subnet_cidr" {
  default = ""
}

variable "master_ip" {
  default = ""
}
variable "slave1_ip" {
  default = ""
}

variable "slave2_ip" {
  default = ""
}

variable "image" {
  default = ""
}

variable "master_image" {
  default = ""
}

variable "slave_image" {
  default = ""
}

variable "haproxy_image" {
  default = ""
}

variable "db_password" {
  default = ""
}

variable  "region" {
  default = ""
}

variable "project" {
  default = ""
}

variable "machine_type" {
  default = ""
}


variable "startup_scripts" {
  type = "map"
  default = {
    nat = "sudo sysctl -w net.ipv4.ip_forward=1; sudo iptables -t nat -A POSTROUTING -o ens4 -j MASQUERADE"
    haproxy = "cd /home/packer; sudo su - packer; sudo chmod +x haproxy.sh; bash haproxy.sh"
    slave = "cd /home/packer; sudo su - packer; sudo chmod +x slave_config.sh; bash slavedb_setup.sh"
    master = "cd /home/packer; sudo su - packer; sudo chmod +x slave_config.sh; bash masterdb_setup.sh"
  }
}
