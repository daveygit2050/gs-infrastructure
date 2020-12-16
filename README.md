# gs-infrastructure
Configuration management for Gold Square infrastructure

## Bootstraping a new pi

Follow these steps to add a new Raspberry Pi to the cluster.

### Create Raspbian SD card

1. Download the desired version of [Raspbian](https://www.raspberrypi.org/downloads/raspbian/)
1. Insert a micro SD card and use `lsblk` to determine the disk name (e.g. `mmcblk0`)
1. Run `unzip {downloaded-file}.zip`
1. Run `sudo ddrescue -d -D --force {extracted-file}.img /dev/{device-name}`

### Perform initial operating system configuration

1. Insert the micro SD card into the Pi and boot it up
1. Determine the address that has been assigned to the Pi using nmap
1. Connect to the Pi with SSH as the `pi` user (default password `raspberry`)
1. Modify `/etc/dhcpcd.conf`, adding static IP address config (example below) to the bottom of the file
1. Reboot the Pi

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
