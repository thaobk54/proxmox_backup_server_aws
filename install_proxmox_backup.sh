#!/bin/bash
set -ex

# sudo mkdir /tmp/ssm
# cd /tmp/ssm
# wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
# sudo dpkg -i amazon-ssm-agent.deb
# sudo systemctl enable amazon-ssm-agent
# rm amazon-ssm-agent.deb

sudo su 

apt-get install wget -y

wget https://enterprise.proxmox.com/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
sha512sum /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg


echo deb http://ftp.debian.org/debian bullseye main contrib >> /etc/apt/sources.list
echo deb http://ftp.debian.org/debian bullseye-updates main contrib >> /etc/apt/sources.list


echo deb http://download.proxmox.com/debian/pbs bullseye pbs-no-subscription >> /etc/apt/sources.list


echo deb http://security.debian.org/debian-security bullseye-security main contrib >> /etc/apt/sources.list

apt-get update -y

apt install proxmox-backup ifupdown -y

apt dist-upgrade -y

passwd root
# Then a new passwd will be asked, so enter new passwd and then confirm it. 
#then make sure you reboot.
reboot

