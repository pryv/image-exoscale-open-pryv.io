## Variables
#  REF: https://www.packer.io/docs/templates/hcl_templates/blocks/variable

variable "ssh_private_key_file" {
  description = "Path to the SSH private key file corresponding to the public key passed in the user-data (seed.img)"
  type        = string
  default     = env("PACKER_PRIVATE_KEY")
}


## Local variables
#  REF: https://www.packer.io/docs/templates/hcl_templates/locals

locals {
  image = "${basename(abspath(path.root))}"
}


## Source
#  REF: https://www.packer.io/docs/templates/hcl_templates/blocks/source

# QEMU / KVM
# REF: https://www.packer.io/docs/builders/qemu
source "qemu" "image" {
  # Image
  iso_url      = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  iso_checksum = "file:https://cloud-images.ubuntu.com/jammy/current/SHA256SUMS"
  # (output)
  output_directory = "${path.cwd}/output-qemu"
  vm_name          = "${local.image}.qcow2"

  # QEMU / KVM
  qemuargs = [
    ["-cpu", "qemu64,rdrand=on"],
    ["-drive", "file=${path.cwd}/output-qemu/${local.image}.qcow2,format=qcow2,if=virtio"],
    ["-drive", "file=${path.cwd}/secrets/seed.img,format=raw,if=virtio"]
  ]
  memory   = 1024
  # (disk)
  format           = "qcow2"
  disk_interface   = "virtio"
  disk_image       = true
  disk_size        = 10240
  disk_compression = true
  # (network)
  net_device = "virtio-net"

  # Communicators
  # (VNC <-> Boot)
  use_default_display = true
  # (SSH <-> Provisioner)
  communicator         = "ssh"
  ssh_username         = "ubuntu"
  ssh_private_key_file = "${var.ssh_private_key_file}"
  ssh_timeout          = "30m"

  # Shutdown
  shutdown_command = "sudo rm -f /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys && echo 'packer' | sudo -S shutdown -P now"
}


## Build
#  REF: https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.qemu.image"]

  ## Provisioners
  # REF: https://www.packer.io/docs/provisioners

  # File
  # REF: https://www.packer.io/docs/provisioners/file
  provisioner "file" {
    source      = "${path.root}/cloud-init"
    destination = "/tmp/"
  }

  provisioner "file" {
    destination = "/home/ubuntu/"
    sources = [
      "${local.image}/config.yml",
      "${local.image}/default",
      "${local.image}/openpryv.sh",
      "${local.image}/setup.js",
      "${local.image}/openpryv.service"
    ]
  }

  # Shell
  # REF: https://www.packer.io/docs/provisioners/shell
  provisioner "shell" {
    execute_command = "chmod +x {{.Path}}; sudo {{.Path}}"
    scripts         = [
      "${path.cwd}/scripts/motd-news-telemetry-disable.sh",
      "${path.cwd}/scripts/grub-exoscale.sh",
      "${path.cwd}/scripts/apt-dist-upgrade.sh",
      "${local.image}/script.sh",
      "${path.cwd}/scripts/apt-cleanup.sh",
      "${path.cwd}/scripts/cloud-cleanup.sh",
      "${path.cwd}/scripts/dhcp-cleanup.sh",
      "${path.cwd}/scripts/history-cleanup.sh",
      "${path.cwd}/scripts/machine-id-reset.sh",
      "${path.cwd}/scripts/lock-root.sh",
      "${path.cwd}/scripts/freespace-zero.sh",
    ]
  }
}
