# terraform {
#   required_providers {
#     proxmox = {
#       source = "telmate/proxmox"
#       version = ">= 2.9.14"
#     }
#     kubernetes = {
#       source = "hashicorp/kubernetes"
#       version = ">= 2.20.0"
#     }
#     null = {
#       source = "hashicorp/null"
#       version = ">= 3.2.0"
#     }
#   }
# }

# provider "proxmox" {
#     pm_tls_insecure = true
#     pm_api_url = "https://192.168.0.102:8006/api2/json"
#     pm_password = "Ets240790"
#     pm_user = "root@pam"
#     pm_otp = ""
# }

# # Master Node
# resource "proxmox_lxc" "k8s_master" {
#     features {
#         nesting = true
#     }
#     hostname = "k8s-master"
#     network {
#         name = "eth0"
#         bridge = "vmbr0"
#         ip = "dhcp"
#         ip6 = "dhcp"
#     }
#     ostemplate = "local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
#     password = "password"
#     target_node = "node1"
#     unprivileged = true
#     cores = 2
#     memory = 4096
#     onboot = true
#     start = true
    
#     # Correct startup script format for LXC
#     startup = "order=1"

#     # Use provisioner for post-creation setup
#     provisioner "remote-exec" {
#       inline = [
#         "snap install microk8s --classic --channel=1.28/stable",
#         "sleep 30", # Wait for snap to complete
#         "microk8s status --wait-ready",
#         "microk8s enable dns dashboard storage ingress",
#         "microk8s enable metallb:192.168.0.200-192.168.0.220",
#         "microk8s status --wait-ready",
#         "microk8s add-node | grep 'microk8s join' | head -n1 > /root/join_token.txt",
#         "mkdir -p /root/.kube",
#         "microk8s config > /root/.kube/config"
#       ]

#       connection {
#         type     = "ssh"
#         user     = "root"
#         password = "password"
#         host     = self.network[0].ip
#       }
#     }
# }

# # Worker Node
# resource "proxmox_lxc" "k8s_worker" {
#     features {
#         nesting = true
#     }
#     hostname = "k8s-worker"
#     network {
#         name = "eth0"
#         bridge = "vmbr0"
#         ip = "dhcp"
#         ip6 = "dhcp"
#     }
#     ostemplate = "local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
#     password = "password"
#     target_node = "node2"
#     unprivileged = true
#     cores = 2
#     memory = 4096
#     onboot = true
#     start = true

#     # Correct startup script format for LXC
#     startup = "order=2"
# }

# # Configure cluster
# resource "null_resource" "cluster_config" {
#   depends_on = [proxmox_lxc.k8s_master, proxmox_lxc.k8s_worker]

#   triggers = {
#     master_ip = proxmox_lxc.k8s_master.network[0].ip
#     worker_ip = proxmox_lxc.k8s_worker.network[0].ip
#   }

#   # Install MicroK8s on worker and join cluster
#   provisioner "remote-exec" {
#     inline = [
#       "snap install microk8s --classic --channel=1.28/stable",
#       "sleep 30", # Wait for snap to complete
#       "microk8s status --wait-ready",
#       "JOIN_CMD=$(ssh -o StrictHostKeyChecking=no root@${proxmox_lxc.k8s_master.network[0].ip} 'cat /root/join_token.txt')",
#       "$JOIN_CMD"
#     ]

#     connection {
#       type     = "ssh"
#       user     = "root"
#       password = "password"
#       host     = proxmox_lxc.k8s_worker.network[0].ip
#     }
#   }

#   # Get kubeconfig
#   provisioner "local-exec" {
#     command = <<-EOT
#       sleep 30
#       ssh -o StrictHostKeyChecking=no root@${proxmox_lxc.k8s_master.network[0].ip} 'microk8s config' > kubeconfig.yaml
#     EOT
#   }
# }

# # Kubernetes provider configuration with proper dependency
# provider "kubernetes" {
#   # We'll configure the provider only after we have the kubeconfig
#   config_path = fileexists("kubeconfig.yaml") ? "kubeconfig.yaml" : null
# }

# # Create namespace
# resource "kubernetes_namespace" "web_app" {
#   depends_on = [null_resource.cluster_config]
  
#   metadata {
#     name = "web-app"
#   }
# }

# # Rest of the configuration remains the same...
# # (kubernetes_deployment and kubernetes_service resources)

# # Outputs
# output "master_ip" {
#     value = proxmox_lxc.k8s_master.network[0].ip
# }

# output "worker_ip" {
#     value = proxmox_lxc.k8s_worker.network[0].ip
# }

# output "next_steps" {
#     value = <<-EOT
#       Cluster is being initialized. Please wait a few minutes for all services to start.
      
#       Verify cluster status:
#       1. SSH to master node: ssh root@${proxmox_lxc.k8s_master.network[0].ip}
#       2. Check nodes: microk8s kubectl get nodes
#       3. Check pods: microk8s kubectl get pods -A
      
#       Access services:
#       1. Check service IP: microk8s kubectl get svc -n web-app
#       2. Access the application at http://<service-external-ip>
#     EOT
# }