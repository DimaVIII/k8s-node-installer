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
sudo apt update -y && sudo apt upgrade -y
```

## Reboot on kernal update
```
reboot
```

# Install
```bash
curl https://raw.githubusercontent.com/DimaVIII/k8s-node-installer/main/node.sh | sudo sh
```

---

# Extras

## Install Calico Networking plugin
```
curl https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/custom-resources.yaml -o calico-config.yaml
```

// Edit calico-config.yaml (custom-resources.yaml)
```
nano calico-config.yaml
```

// Install Calico Networking plugin
```
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/tigera-operator.yaml
```

// Apply calico-config.yaml
```
kubectl create -f calico-config.yaml
```

// Fix interface autodetection (DigitalOcean Node issue)
// spec:calicoNetwork:NodeAddressAutodetectionV4 - Doesn't work
```
kubectl set env daemonset.apps/calico-node -n calico-system IP_AUTODETECTION_METHOD=can-reach=www.google.com

// Verify podcrid
kubectl get nodes -o yaml | grep -i podcidr

// Verify projectcalico.org/IPv4Address is the public IP of the node
kubectl get nodes -o yaml
```
