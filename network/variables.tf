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

variable  "region" {
  default = ""
}

variable "project" {
  default = ""
}



variable "startup_scripts" {
  type = "map"
  default = {
    nat = "sudo sysctl -w net.ipv4.ip_forward=1; sudo iptables -t nat -A POSTROUTING -o ens4 -j MASQUERADE"
    haproxy = "cd /home/packer; sudo su - packer; sudo chmod +x haproxy.sh; bash haproxy.sh"
  }
}
