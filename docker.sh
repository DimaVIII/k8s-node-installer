#!/bin/bash
#
# Docker Installation - Ubuntu 22.04 LTS
#

# Update
sudo apt update -y

# Tools
sudo apt install -y tree jq net-tools fping systemd-timesyncd nano git openssl

# Set time sync
sudo systemctl enable systemd-timesyncd.service
sudo systemctl start systemd-timesyncd.service
sudo timedatectl set-ntp on

# Swap off
#sudo swapoff -a
#sudo sed -i.bak '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

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
sudo apt install docker-ce docker-ce-cli docker-compose -y
# sudo apt install containerd.io -y

### Daemon config
cat <<EOF | sudo tee /etc/docker/daemon.json
{
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "10"
    },
    "storage-driver": "overlay2"
}
EOF

### Enable docker
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker

cat <<EOF >> /root/.bashrc
# Color
force_color_prompt=yes
color_prompt=yes

# GIT bash integration
if [[ -e /usr/lib/git-core/git-sh-prompt ]]; then
    source /usr/lib/git-core/git-sh-prompt

    export GIT_PS1_SHOWCOLORHINTS=true
    export GIT_PS1_SHOWDIRTYSTATE=true
    export GIT_PS1_SHOWUNTRACKEDFILES=true
    export GIT_PS1_SHOWUPSTREAM="auto"
    # PROMPT_COMMAND='__git_ps1 "\u@\h:\w" "\\\$ "'

    # use existing PS1 settings
    PROMPT_COMMAND=$(sed -r 's|^(.+)(\\\$\s*)$|__git_ps1 "\1" "\2"|' <<< $PS1)
fi

## Alias
alias l='ls -lah'
alias ll='ls -lh'
alias la='ls -lah'
alias du='du -h'
alias df='df -h'
alias untar='tar -xvf'
alias utar='tar -xvf'
alias g='git'
alias gs='git status'
alias d='docker'
alias dil='docker image list'
alias dc='docker-compose'
alias tree='tree -a'
EOF

echo '\nDocker installation done!'

exit 0
