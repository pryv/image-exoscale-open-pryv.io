#!/bin/sh
SCRIPT="${0##*/}"

## GRUB configuration
echo "INFO[${SCRIPT}]: Configuring GRUB bootloader ..."
mkdir -p /etc/default/grub.d

# remove Cloud Image specific Grub settings for Generic Cloud Images
rm -f /etc/default/grub.d/50-cloudimg-settings.cfg

# boot: setup kernel to output to tty0, ttyS0 and use ethX
echo 'GRUB_CMDLINE_LINUX_DEFAULT="elevator=deadline net.ifnames=0 biosdevname=0 console=tty0 console=ttyS0,115200 consoleblank=0 systemd.show_status=true"' > /etc/default/grub.d/60-exoscale.cfg


## Distribution-specific quirks
distrib="$(sed -nE 's|^DISTRIB_ID=(.*)$|\1|p' /etc/lsb-release)"
release="$(sed -nE 's|^DISTRIB_RELEASE=(.*)$|\1|p' /etc/lsb-release)"
codename="$(sed -nE 's|^DISTRIB_CODENAME=(.*)$|\1|p' /etc/lsb-release)"

# Ubuntu (UEFI)
# Seems that grub-efi and terminal_output=gfxterm break Cloudstack
# console. Let's fallback to terminal_output=console for Bionic,
# Focal, Groovy (release >= 18) grub2 configuration, refer to ch17180 for more.

# Bionic, Focal, Groovy (release >= 18): "error: can't find command hwmatch"
# Workaround: GRUB_GFXPAYLOAD_LINUX=keep
# https://bugs.launchpad.net/ubuntu/+source/grub2-signed/+bug/1840560
if [ "${distrib}" = "Ubuntu" -a ${release%.*} -ge 18 ]; then
  cat <<EOF >>/etc/default/grub.d/60-exoscale.cfg
GRUB_TERMINAL=console
GRUB_GFXPAYLOAD_LINUX=keep

EOF
fi

# Focal: GRUB_RECORDFAIL_TIMEOUT
# https://bugs.launchpad.net/ubuntu/+source/grub2/+bug/1814403
# https://bugs.launchpad.net/ubuntu/+source/grub2/+bug/1815002
if [ "${codename}" = "focal" ]; then
  cat <<EOF >>/etc/default/grub.d/60-exoscale.cfg
GRUB_RECORDFAIL_TIMEOUT=3

EOF
fi


## Enforce configuration changes
update-grub
