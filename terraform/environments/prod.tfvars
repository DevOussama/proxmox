environment = "prod"
proxmox_endpoint = "https://192.168.0.104:8006/api2/json"
proxmox_username = "root@pam"
# proxmox_node = "node01"
proxmox_password = "password"
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICCjGUt7IgX8HsmG4apLRAXhih05XDA7XE1OZ1hjfC1A otanfous@gmail.com"
network_config = {
  gateway_ip = "192.168.0.1"
  dns_servers = ["192.168.0.1"]
  subnet_mask = "24"
}

nodes = [
  {
    name = "master-node"
    role = "master"
    ip_address = "192.168.0.204"
    vm_id = 4320
    cpu_cores = 2
    memory = 2048
    disk_size = 32
    node_name = "node4"
  },
  {
    name = "worker-node-1"
    role = "worker"
    ip_address = "192.168.0.205"
    vm_id = 4321
    cpu_cores = 2
    memory = 2048
    disk_size = 32
    node_name = "node4"
  },
  # {
  #   name = "master-node"
  #   role = "master"
  #   ip_address = "192.168.0.202"
  #   vm_id = 4322
  #   cpu_cores = 2
  #   memory = 2048
  #   disk_size = 32
  #   node_name = "node03"
  # }
]
