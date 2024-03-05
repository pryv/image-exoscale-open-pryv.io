#!/bin/sh
SCRIPT="${0##*/}"

## cloud-init cleanup/reset
echo "INFO[${SCRIPT}]: Cleaning-up (resetting) cloud-init ..."

# kill any running cloud-init instance before messing with it
pkill cloud-init

# move custom (Packer-ed) configuration files and change permissions
mv -v /tmp/cloud-init/* /etc/cloud/cloud.cfg.d/
chown -R root:root /etc/cloud/cloud.cfg.d/

# cleanup cloud-init data
cloud-init clean
mkdir -p /var/lib/cloud
rm -rf /var/lib/cloud/*
ln -s /var/lib/cloud/instances /var/lib/cloud/instance

# cleanup cloud-init logs
rm -rf /var/log/cloud-init*

# cleanup tmp files
rm -rf /tmp/cloud-init
