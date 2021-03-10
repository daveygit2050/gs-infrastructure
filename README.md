# gs-infrastructure
Configuration management for Gold Square infrastructure.

## Bootstraping a new Pi

Follow these steps to add a new Raspberry Pi to the cluster.

### Perform initial operating system configuration

1. Download the desired version of [Ubuntu Server for Raspberry Pi](https://ubuntu.com/download/raspberry-pi).
1. Write the image to a micro SD card as per the instructions.
1. Insert the micro SD card into the Pi and boot it up.
1. Determine the address that has been assigned to the Pi (e.g. by using nmap).
1. Connect to the Pi with SSH as the `ubuntu` user (default password `ubuntu`).
1. Set a reasonably secure temporary password and reconnect. If it asks to change it again, try again in a few minutes or reboot the Pi.
1. Become root with `sudo su -`.
1. Modify `/etc/netplan/50-cloud-init.yaml`, adding static IP address config (example below) to the bottom of the file.
1. Run `netplan apply` to update the network configuration. This will disconnect the SSH session.
1. Reconnect the SSH session to add the host key fingerprint, then disconnect.

#### Example static IP address configuration

```
network:
    ethernets:
        eth0:
            dhcp4: no
            addresses: [192.168.0.201/24]
            gateway4: 192.168.0.1
            nameservers:
                addresses: [192.168.0.1]
    version: 2
```

### AWS Systems Manager bootstrap process

Run `init.sh` to prepare a local development environment.  Activate the venv virtual environment.

Run `bootstrap.sh`, with the desired hostname and IP address of the Pi as arguments and AWS auth. E.g...

```
aws-vault exec gs-admin -- ./bootstrap.sh pi01 192.168.0.201
```

This will bootstrap the Pi with Ansible and register it with AWS Systems Manager.

## Applying state changes

Use `apply.sh` to keep everything up to date.
