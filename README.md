# gs-infrastructure
Configuration management for Gold Square infrastructure.

## Bootstraping a new Pi

Follow these steps to add a new Raspberry Pi to the cluster.

### Perform initial operating system configuration

1. Download the desired version of [Ubuntu Server for Raspberry Pi](https://ubuntu.com/download/raspberry-pi).
1. Write the image to a micro SD card using the `Raspberry Pi Imager` per the instructions.
1. Modify the `network-config` file on the SD card using with a static IP settings (example below).
1. Insert the micro SD card into the Pi and boot it up.
1. Connect to the Pi with SSH as the `ubuntu` user (default password `ubuntu`).
1. Set a reasonably secure temporary password and reconnect. If it asks to change it again, try again in a few minutes or reboot the Pi.

#### Example static IP address configuration

```
version: 2
ethernets:
    eth0:
        dhcp4: no
        addresses: [192.168.0.201/24]
        gateway4: 192.168.0.1
        nameservers:
            addresses: [192.168.0.1]
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

## Managing k8s resources

1. Copy the appropriate manifest file from `k8s-manifests\` to pi01.
1. Run `microk8s kubectl apply -f ${manifest-name}.yml`.

### Pihole

1. Create a secret for the admin password: `microk8s kubectl create secret generic pihole-secrets --from-literal=admin-password='foo-password' --namespace pihole`
2. Apply the `pihole.yaml` manifest as above.
