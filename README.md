# gs-infrastructure
Configuration management for Gold Square infrastructure

## Bootstraping a new pi

Follow these steps to add a new Raspberry Pi to the cluster.

### Create Raspbian SD card

1. Download the desired version of [Raspbian Stretch Lite](https://www.raspberrypi.org/downloads/raspbian/)
1. Insert a micro SD card and use `lsblk` to determine the disk name (e.g. `mmcblk0`)
1. Run `unzip {downloaded-file}.zip`
1. Run `sudo ddrescue -d -D --force {extracted-file}.img /dev/{device-name}`

### Perform initial operating system configuration

1. Insert the micro SD card into the Pi and boot it up
1. Login as the `pi` user (default password `raspberry`)
1. Modify `/etc/dhcpcd.conf`, adding static IP address config (example below) to the bottom of the file
1. Use `sudo raspi-config` to enable SSH server
1. Reboot the Pi, or shut it down so it can be connected to the cluster

#### Example static IP address configuration

```
interface eth0

static ip_address=192.168.0.201/24
static routers=192.168.0.1
static domain_name_servers=192.168.0.1
```

### AWS Systems Manager bootstrap process

Run `bootstrap.sh`, with the desired hostname and IP address of the Pi as arguments. E.g...

```
./bootstrap.sh pi01 192.168.0.201
```

This will bootstrap the Pi with Ansible and register it with AWS Systems Manager.

## Playbook operations

Playbooks can be either scheduled or manually triggered.

### Scheduled playbooks

Playbooks are scheduled by deploying an SSM assocation with terraform. At present, only the `ansible/pis-ssm-daily.yml` playbook is executed on all pis on a daily basis.

### Manual playbooks

All the playbooks within the `ansible` directory starting with `pis-ssm` can be manually executed. In order to manually execute a playbook, run `pipenv run scripts/run-playbook.py {playbook-name}`. You can also pass in the following optional parameters...

* `--branch` - use this if the version of the playbook you want to run is in a branch other than `master`
* `--names` - if you want to filter the playbook to only run on certain pis, use this to specify them by name. Multiple pis can be specified by comma seperating them 

## Todo

* Automatically create tags on managed instance after registration
