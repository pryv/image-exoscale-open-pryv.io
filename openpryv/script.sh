#!/bin/sh
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get update
apt-get install nodejs git nginx-core gcc g++ make -y

snap install --classic certbot

mkdir /var/pryv
