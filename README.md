# K8S - Node installer for Ubuntu 22.04 LTS

Created on 28-Oct-2022

Currrent K8S_VERSION="1.25.3-00"

## Install
```bash
curl | sudo sh
```

## Set Hostname
```
hostnamectl
sudo hostnamectl set-hostname k8s-node-1
```

Add hostname to /etc/hosts
```
sudo nano /etc/hosts
```
