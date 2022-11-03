#!/bin/bash
#
# K8S - Node installer for Ubuntu 22.04 LTS
# Created on 28-Oct-2022
#

# Vars
K8S_VERSION="1.25.3-00"

# Update
sudo apt update -y

# Tools
sudo apt install -y tree jq net-tools fping systemd-timesyncd nano

# Set time sync
sudo systemctl enable systemd-timesyncd.service
sudo systemctl start systemd-timesyncd.service
sudo timedatectl set-ntp on

# Swap off
sudo swapoff -a
sudo sed -i.bak '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Forwarding IPv4 and letting iptables see bridged traffic
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# Fine tunning OS
sudo sysctl -w net.netfilter.nf_conntrack_max=1000000
echo "net.netfilter.nf_conntrack_max=1000000" >> /etc/sysctl.conf

# Install container engine
sudo apt update -y
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y
# sudo apt install docker-ce docker-ce-cli containerd.io -y
sudo apt install containerd.io -y

### Daemon config
# cat <<EOF | sudo tee /etc/docker/daemon.json
# {
#   "exec-opts": ["native.cgroupdriver=systemd"],
#   "log-driver": "json-file",
#   "log-opts": {
#     "max-size": "100m"
#   },
#   "storage-driver": "overlay2"
# }
# EOF

### Enable docker
# sudo systemctl enable docker
# sudo systemctl daemon-reload
# sudo systemctl restart docker

### Setup containerd
sudo bash -c 'containerd config default > /etc/containerd/config.toml'
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl enable containerd
sudo systemctl restart containerd

# Install Kubeadm + Kubelet + Kubectl
sudo apt update -y
sudo apt install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update -y
sudo apt install -y kubeadm=$K8S_VERSION kubelet=$K8S_VERSION  kubectl=$K8S_VERSION

# Hold updates
sudo apt-mark hold kubelet kubeadm kubectl

# Fix crictl warning
/usr/bin/crictl config runtime-endpoint unix:///var/run/containerd/containerd.sock

#TODO: Firewall
#ufw enable
#or
#iptables

# Master Firewall
# sudo ufw allow 6443/tcp
# ufw allow 2379/tcp
# sudo ufw allow 2380/tcp
# sudo ufw allow 10250/tcp
# sudo ufw allow 10257/tcp
# sudo ufw allow 10259/tcp
# sudo ufw reload

# Worker Firewall
# sudo ufw allow 10250/tcp
# sudo ufw allow 30000:32767/tcp
# sudo ufw reload

# Add alias for kubectl
cat <<EOF >> /root/.bashrc
## Kubernetes - K8S
alias k="kubectl"
alias kg="kubectl -o wide get"
alias kga="kubectl get all -o wide"
alias kgaa="kubectl get all -o wide -A"
alias kgp="kubectl get po -o wide"
alias kgpa="kubectl get po -o wide -A"

alias kgpm="kubectl get pod -o wide -n monitoring"
alias kgam="kubectl get all -o wide -n monitoring"

source <(kubectl completion bash)
complete -o default -F __start_kubectl k

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
EOF

echo '\nKubernetes installation done!'

exit 0
