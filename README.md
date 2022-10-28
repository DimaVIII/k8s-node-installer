# K8S - Node installer for Ubuntu 22.04 LTS

Created on 28-Oct-2022

Currrent K8S_VERSION="1.25.3-00"

# Prepare the node

## Set Hostname
```
sudo hostnamectl set-hostname k8s-node-1
```
-> exit & re-login

// Verify hostname change
```
hostnamectl
```

Add hostname to /etc/hosts
```
sudo nano /etc/hosts
```

## Update & Upgrade
```
apt update -y && apt upgrade -y
```

## Reboot on kernal update
```
reboot
```

# Install
```bash
curl https://raw.githubusercontent.com/DimaVIII/k8s-node-installer/main/node.sh | sudo sh
```

