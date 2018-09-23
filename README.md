# gs-infrastructure
Configuration management for Gold Square infrastructure

## Bootstraping a new pi

Follow these steps to add a new Raspberry Pi to the cluster.

### Initial Operating System configuration

1. Download the desired version of Ubuntu Server from [Ubuntu Pi Flavour Maker](https://ubuntu-pi-flavour-maker.org/download/)
1. Insert a micro SD card and use `lsblk` to determine the disk name (e.g. `mmcblk0`)
1. Run `unzx {downloaded-file}.img.xz`
1. Run `sudo ddrescue -d -D --force {extracted-file}.img /dev/{device-name}`
1. Insert the micro SD card into the Pi and boot it up
1. Login as the `ubuntu` user and change the default password (also `ubuntu`)
1. Edit `/etc/network/interfaces.d/50-cloud-init.cfg` and configure static IP address settings (example below)
1. Reboot the Pi, or shut it down so it can be connected to the cluster

### Example static IP address configuration

```
auto eth0
iface eth0 inet static
  address 192.168.0.201
  netmask 255.255.255.0
  network 192.168.0.0
  gateway 192.168.0.1
  dns-nameservers 192.168.0.1
```
