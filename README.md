# gs-infrastructure
Configuration management for Gold Square infrastructure

## Bootstraping a new pi

Follow these steps to add a new Raspberry Pi to the cluster.

### Initial Operating System configuration

1. Download the desired version of [Raspbian Stretch Lite](https://www.raspberrypi.org/downloads/raspbian/)
1. Insert a micro SD card and use `lsblk` to determine the disk name (e.g. `mmcblk0`)
1. Run `unzip {downloaded-file}.zip`
1. Run `sudo ddrescue -d -D --force {extracted-file}.img /dev/{device-name}`
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

### Ansible bootstrap process

1. Add entry for the new Pi to `ansible/inventories/pis`
1. Run bootstrap (e.g. `ansible-playbook -i inventories/pis -u pi -k -l pi01 pis.yml`)
