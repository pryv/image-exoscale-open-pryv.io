# Open-Pryv.io image for Exoscale

## Description

This tutorial will guide you to:  

- create a new virtual machine (VM)
- configure the VM with the [Open Pryv.io](https://github.com/pryv/open-pryv.io/) template.

## Requirements

- Account on Exoscale
- DNS zone to define a type-A record

## Usage

### Setup Instance of the image

#### Create Firewall rules

To create new Firewall rules, go to COMPUTE>FIREWALLING and then click on the ADD button. You can create the group `pryv` and click on CREATE. You can then select the group `pryv` and add new rules as shown on the screenshot below.

![Firewall](./images/firewall.png)

- TCP 443 is necessary for HTTPS
- TCP 80 is handy for HTTP to HTTPS redirection
- TCP 22 is used for SSH

#### Create Instance

To create a new instance, go to COMPUTE>INSTANCES and then click on the ADD button. You can choose the hostname of the machine and build the configuration as shown on the screenshot below.

![Create Instance 1](./images/create_instance_1.png)

Then select the Security Group `pryv` and copy the **whole** content of the snippet (you need to include `#cloud-config`) below replacing **${HOSTNAME}**, **${SECRET_KEY}** and **${EMAIL}** in the field `User Data` of the form.  

- **${HOSTNAME}** : Hostname on which your Open-Pryv.io platform is exposed. You will need to define a DNS A record for this hostname.
- **${SECRET_KEY}** : This key must be randomly generated and is used as the admin access key
- **${EMAIL}** : This email is only used by Letsencrypt to give you information about your certificate and for recovery purposes ([Link to Letsencrypt](https://letsencrypt.org/fr/privacy/#subscriber)).

```yaml 
#cloud-config
write_files:
- content: |
    {
      "HOSTNAME": "${HOSTNAME}",
      "EMAIL": "${EMAIL}",
      "KEY": "${SECRET_KEY}"
    }
  path: /tmp/conf/config.json

runcmd:
 - node /home/ubuntu/setup.js
```

![Create Instance 2](./images/create_instance_2.png)

#### DNS Record

Once your machine is started, look at the IP address attributed to your machine (see screenshot below) and create an A record in your DNS zone with the ${HOSTNAME} you furnished before.

![IP address](./images/ip.png)

### Log

The first boot can take up to 10 minutes.

To follow the set-up process, connect in ssh inside your VM and read the log file `/home/ubuntu/setup.log`.

```sh
tail -f /home/ubuntu/setup.log
```

During the setup phase, the script will wait until you add the DNS A record. 

### Verify

Your Open Pryv.io platform is now running at `https://${HOSTNAME}/`.  
You should get a service information similar to the one below:

```
{
  "meta": {
    "apiVersion": "1.5.24-open",
    "serverTime": 1601379119.307,
    "serial": "t1591793506"
  },
  "cheersFrom": "Pryv API",
  "learnMoreAt": "https://api.pryv.com/"
}
```

Follow these steps to start using the platform: [Open Pryv.io - Start](https://github.com/pryv/open-pryv.io#start).

### What next

You can personalize your Open Pryv.io platform and configure company email by following the [README of the git repo of Open-Pryv.io](https://github.com/pryv/open-pryv.io/).

## Contribute 

### How it works

- The image is created with `./build.sh` (linux) or `./build-docker.sh` (Docker based for OSX) 
- The image contains a set of tasks to be run at boot
  1. Install necessary components
  2. Clone Open Pryv.io from Github - So the latest version of Open Pryv.io is installed at first boot
  3. Setup Open Pryv.io environment
  4. Build Open Pryv.io
  5. Run Open Pryv.io
- The image should be uploaded on a HTTP server and published

### Requirements

- An exoscale account on exoscale with a registered SSH key without a password (in the examples `~/.ssh/exo.pub`, `~/.ssh/exo`)
- To upload the image on exoscale:
  - a "bucket" in "storage" (for the example `open-pryv-templates`)
- [Exoscale Cli](https://github.com/exoscale/cli) installed with an **IAM API key** with **write** permission on the bucket. (In the example it's installed under ./cli/)
- On **OSX** you need to have [Docker](https://docs.docker.com/docker-for-mac/install/) installed.

### Build Image

To modify the image or add modules, you can modify the file `openpryv/script.sh` and/or add files in `openpryv/` and add them in the build by modifying `openpryv/packer.json`.

To build a new image, use the SSH key registered in Exoscale (for example `~/.ssh/exo.pub`and `~/.ssh/exo`).  
*be patient, it can be fairly long*

- On MacOS, you have to start a docker daemon and run at the root of the project: 
  
```bash
PACKER_PUBLIC_KEY=~/.ssh/exo.pub PACKER_PRIVATE_KEY=~/.ssh/exo ./build-docker.sh OPENPRYV
```

- On Linux, at the root of the project run: 

```bash
PACKER_PUBLIC_KEY=~/.ssh/exo.pub PACKER_PRIVATE_KEY=~/.ssh/exo ./build.sh OPENPRYV
```

On success the image will be created in `./output-qemu/openpryv.qcow2`

### Upload Image on Exoscale Bucket

Using Exoscale CLI: `path_to_exoscale_cli/exo sos upload open-pryv-templates ./output-qemu/openpryv.qcow2`

Then you can connect to the  [Exoscale Console](https://portal.exoscale.com/) and go to Storage. Click on your bucket and you can normally see `openpryv.qcow2`.

### References

Creating Custom Templates [Using Packer](https://www.exoscale.com/syslog/creating-custom-templates-using-packer/)

To create a template, you have to host the image on a publicly accessible HTTPS service such as Exoscale [Object Storage](https://community.exoscale.com/documentation/storage/), as you will need to indicate a URL pointing to it during template registration. Click on it, and at the bottom of the page, click on `Quick ACL` and then on `public read`.


To create a new template, you have to connect to your [Exoscale Console](https://portal.exoscale.com/), and go to Compute/Templates. You can select the data center of your choice and click on `register`. Then you can indicate the name of the template and the description. You add also the URL to the image and the md5 of the image (run `md5 ./output-qemu/openpryv.qcow2`). The username is `ubuntu`.

Note that you have to create a new template for each data center you want to use.

![Create template](./images/create_template.png)

## Marketplace

- Informations on the [Marketplace & Templates](https://community.exoscale.com/documentation/vendor/marketplace-templates/)  
- Templates [Technical Requirements](https://community.exoscale.com/documentation/vendor/marketplace-templates-tech-requirements/)  
