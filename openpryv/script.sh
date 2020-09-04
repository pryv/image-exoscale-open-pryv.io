#!/bin/sh
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
apt-get update
apt-get install nodejs git nginx-core -y
apt install npm -y

snap install --classic certbot

update-grub
npm install -g yarn
git clone https://github.com/pryv/open-pryv.io.git

# cloud-init: Remove Cloud Image specific Grub settings for Generic Cloud Images
[ -f /etc/default/grub.d/50-cloudimg-settings.cfg ] && rm /etc/default/grub.d/50-cloudimg-settings.cfg

# clean for real
cloud-init clean