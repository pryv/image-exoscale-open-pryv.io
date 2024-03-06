#!/bin/bash

IMAGE="openpryv"

if [ -z "$(which cloud-localds)" ]; then
    error "Error: could not find cloud-localds. Please install the cloud image utilities."
    usage
    exit 1
fi

if [ -z "$(which packer)" ]; then
    error "Error: could not find packer. Please install packer."
    usage
    exit 1
fi

# change directory to script location
cd "$(dirname "$0")"

#ulimit -H -n 65535
#ulimit -S -n 65535

# Generate an local ssh key used in the building process
# using ed25519 type of keys as rsa was hanging the process

PACKER_PRIVATE_KEY="./secrets/id_ed25519"
PACKER_PUBLIC_KEY="./secrets/id_ed25519.pub"
PACKER_USER_DATA="./secrets/user-data"
PACKER_SEED_IMG="./secrets/seed.img"

if [ ! -d "./secrets" ]; then mkdir ./secrets ; fi

if [ ! -f ${PACKER_PRIVATE_KEY} ]; then ssh-keygen -N '' -t ed25519 -f ${PACKER_PRIVATE_KEY} ; fi

if [ ! -f ${PACKER_USER_DATA} ];
then 
public_key=$(cat ${PACKER_PUBLIC_KEY})
# generate cloud init user data
cat <<EOF > ${PACKER_USER_DATA}
#cloud-config
ssh_authorized_keys:
- "${public_key}"
EOF
fi

# build cloud init disk
if [ ! -f ${PACKER_SEED_IMG} ]; then cloud-localds ${PACKER_SEED_IMG} ${PACKER_USER_DATA} ; fi

packer build ./${IMAGE}/
