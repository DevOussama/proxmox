#!/bin/bash
#  - Put this script in '/var/lib/vz/snippets/master_init.sh' where
#    the 'local:' storage maps to the directory : /var/lib/vz
# Update package list and install snapd with non-interactive options
echo "Updating package list..."
sudo apt update -y

echo "Installing snapd..."
sudo apt install -y snapd

# Confirm that snapd was installed
if command -v snap >/dev/null; then
    echo "snapd installed successfully."
else
    echo "Error: snapd installation failed."
    exit 1
fi
# Install MicroK8s with the specified version
snap install microk8s --classic --channel=1.28/stable

# Wait for Snap installation to complete
sleep 30

# Wait until MicroK8s is ready
microk8s status --wait-ready

# Enable required MicroK8s services
microk8s enable dns dashboard storage ingress

# Configure MetalLB with a specified IP range
microk8s enable metallb:192.168.0.200-192.168.0.220

# Wait again for MicroK8s to become ready after enabling add-ons
microk8s status --wait-ready

# Generate a join command for new nodes and save it to a file
microk8s add-node | grep 'microk8s join' | head -n1 > /root/join_token.txt

# Set up the Kubernetes config directory
mkdir -p /root/.kube

# Export the MicroK8s config to the Kubernetes config file
microk8s config > /root/.kube/config

# Script complete
echo "MicroK8s setup and configuration complete."
