FROM ubuntu:latest

ARG PACKER_VERSION="1.6.6"
ARG PACKER_SHA256SUM="721d119fd70e38d6f2b4ccd8a39daf6b4d36bf5f7640036acafcaaa967b00c3b"

RUN apt-get update && apt-get install -y qemu-system-x86 \
    qemu-utils wget busybox \
    kmod cpio udev lvm2 unzip cloud-utils

RUN wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
        && echo "${PACKER_SHA256SUM} packer_${PACKER_VERSION}_linux_amd64.zip" | sha256sum -c \
        && unzip packer_${PACKER_VERSION}_linux_amd64.zip \
&& mv packer /usr/bin
