terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

provider "proxmox" {
    pm_tls_insecure = true
    pm_api_url = "https://192.168.0.102:8006/api2/json"
    pm_password = "Ets240790"
    pm_user = "root@pam"
    pm_otp = ""
}

resource "proxmox_lxc" "node1VM1" {
    features {
        nesting = true
    }
    hostname = "k8s-master"
    network {
        name = "eth0"
        bridge = "vmbr0"
        ip = "dhcp"
        ip6 = "dhcp"
    }
    ostemplate = "local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
    password = "password"
    # pool = "OussamaCluster"
    target_node = "node1"
    unprivileged = true
    cores = 2
    memory = 4096
    onboot = true
    start = true
    #  - Put this script in '/var/lib/vz/snippets/master_init.sh' where
    #    the 'local:' storage maps to the directory : /var/lib/vz
    hookscript = "local:snippets/master_init.sh"
}

resource "proxmox_lxc" "node2VM1" {
    features {
        nesting = true
    }
    hostname = "k8s-worker"
    network {
        name = "eth0"
        bridge = "vmbr0"
        ip = "dhcp"
        ip6 = "dhcp"
    }
    ostemplate = "local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
    password = "password"
    # pool = "OussamaCluster"
    target_node = "node2"
    unprivileged = true
    cores = 2
    memory = 4096
    onboot = true
    start = true
}
