#cloud-config
hostname: ${hostname}

# Configure password authentication

chpasswd:
  list: |
    ubuntu:ubuntu123
  expire: false

# System packages
packages:
  - qemu-guest-agent
  - openssh-server
  - net-tools

# User configuration
users:
  - name: ubuntu
    groups: [adm, sudo]
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - ${ssh_public_key}

# Configure network
write_files:
  - path: /etc/netplan/00-installer-config.yaml
    content: |
      network:
        version: 2
        ethernets:
          eth0:
            addresses:
              - ${ip_address}
            gateway4: ${gateway_ip}
            nameservers:
              addresses: ${jsonencode(dns_servers)}
    permissions: '0644'
  - path: /etc/ssh/sshd_config.d/allow_passwd_auth.conf
    content: |
      PasswordAuthentication yes
      PermitRootLogin yes
    permissions: '0644'

# System commands
runcmd:
  # Network and system setup
  - netplan apply
  - systemctl restart ssh
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - echo "${hostname}" > /etc/hostname
  - hostnamectl set-hostname ${hostname}
  
  # MicroK8s setup
  - snap install microk8s --classic --channel=1.31
  - usermod -a -G microk8s ubuntu
  - mkdir -p /home/ubuntu/.kube
  - chown -R ubuntu:ubuntu /home/ubuntu/.kube
  - microk8s status --wait-ready
  - microk8s enable dns dashboard
  - microk8s config > /home/ubuntu/.kube/config
  - chown ubuntu:ubuntu /home/ubuntu/.kube/config
  %{ if node_role == "master" }
  - echo "Master node setup completed" > /home/ubuntu/master-setup-complete
  %{ else }
  - echo "Worker node setup completed" > /home/ubuntu/worker-setup-complete
  %{ endif }

# Final message
final_message: "Cloud-init setup completed after $UPTIME seconds"