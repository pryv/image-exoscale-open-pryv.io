#!/bin/sh
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
apt-get update
apt-get install nodejs git nginx-core gcc g++ make -y

snap install --classic certbot
npm install -g yarn

mkdir /var/pryv


update-grub

# cloud-init: Remove Cloud Image specific Grub settings for Generic Cloud Images
[ -f /etc/default/grub.d/50-cloudimg-settings.cfg ] && rm /etc/default/grub.d/50-cloudimg-settings.cfg
# clean for real
cloud-init clean