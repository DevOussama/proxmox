# MicroK8s Remote Access Setup Guide

This guide explains how to set up remote access to your MicroK8s cluster from another machine.

## Prerequisites

- MicroK8s installed on your server
- kubectl installed on your client machine
- Access to both server and client machines
- Server IP address (example used: 192.168.0.200)

## Step 1: Get Cluster Credentials

On your MicroK8s server, run these commands to get the necessary credentials:

### Get Authentication Token

```bash
# Get the dashboard token
sudo microk8s kubectl -n kube-system describe secret microk8s-dashboard-token | grep -E '^token' | cut -f2 -d':' | tr -d " "
```

This command:
1. Lists the secret details (`describe secret`)
2. Gets only the token line (`grep -E '^token'`)
3. Extracts the token value (`cut -f2 -d':'`)
4. Removes extra spaces (`tr -d " "`)

### Get CA Certificate (Optional)

```bash
# Get the cluster CA certificate
sudo microk8s kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}'
```

This command:
1. Views the raw config (`config view --raw`)
2. Extracts the CA certificate using jsonpath
3. The certificate is base64 encoded

## Step 2: Create Kubeconfig File

On your client machine, create a new kubeconfig file:

```bash
# Create directory if it doesn't exist
mkdir -p ~/.kube

# Create the config file
cat << EOF > ~/.kube/microk8s-config
apiVersion: v1
kind: Config
clusters:
- name: microk8s-cluster
  cluster:
    server: https://192.168.0.200:16443
    insecure-skip-tls-verify: true
users:
- name: admin
  user:
    token: <PASTE_TOKEN_HERE>  # Replace with your token from Step 1
contexts:
- name: microk8s
  context:
    cluster: microk8s-cluster
    user: admin
current-context: microk8s
EOF
```

Replace:
- `192.168.0.200` with your server's IP address
- `<PASTE_TOKEN_HERE>` with the token obtained in Step 1

## Step 3: Use the New Configuration

```bash
# Set KUBECONFIG environment variable
export KUBECONFIG=~/.kube/microk8s-config

# Test the connection
kubectl get nodes
```

To make this configuration permanent, add to your shell's RC file:

```bash
# Add to ~/.bashrc or ~/.zshrc
echo "export KUBECONFIG=~/.kube/microk8s-config" >> ~/.bashrc
source ~/.bashrc
```

## Troubleshooting

1. If connection fails, verify:
   - Server IP is correct
   - Port 16443 is accessible
   - Token is correctly copied
   - MicroK8s is running (`sudo microk8s status`)

2. Check API server status:
```bash
# On server
sudo netstat -tlnp | grep 16443
```

3. Verify API server configuration:
```bash
# On server
sudo cat /var/snap/microk8s/current/args/kube-apiserver
```

## Security Considerations

- Using `insecure-skip-tls-verify: true` bypasses certificate verification
- For production environments, proper certificate verification should be enabled
- Consider using firewall rules to restrict access to port 16443
- Regularly rotate authentication tokens

## Additional Resources

- [MicroK8s Documentation](https://microk8s.io/docs)
- [Kubernetes Configuration Best Practices](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/)
