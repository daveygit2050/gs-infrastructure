# gs-infrastructure
Configuration management for Gold Square infrastructure

## Bootstraping a new pi

Follow these steps to add a new Raspberry Pi to the cluster.

### Create Raspbian SD card

1. Download the desired version of [HypriotOS](https://blog.hypriot.com/downloads/)
1. Insert a micro SD card and use `lsblk` to determine the disk name (e.g. `mmcblk0`)
1. Run `unzip {downloaded-file}.zip`
1. Run `sudo ddrescue -d -D --force {extracted-file}.img /dev/{device-name}`

### Perform initial operating system configuration

1. Insert the micro SD card into the Pi and boot it up
1. Determine the address that has been assigned to the Pi using nmap
1. Connect to the Pi with SSH as the `pirate` user (default password `hypriot`)
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

## Playbook operations

Playbooks can be either scheduled or manually triggered.

### Scheduled playbooks

Playbooks are scheduled by deploying an SSM assocation with terraform. At present, only the `ansible/pis-ssm-daily.yml` playbook is executed on all pis on a daily basis.

### Manual playbooks

All the playbooks within the `ansible` directory starting with `pis-ssm` can be manually executed. In order to manually execute a playbook, run `pipenv run scripts/run-playbook.py {playbook-name}`. You can also pass in the following optional parameters...

* `--branch` - use this if the version of the playbook you want to run is in a branch other than `master`
* `--names` - if you want to filter the playbook to only run on certain pis, use this to specify them by name. Multiple pis can be specified by comma seperating them

## Kubernetes setup

This is currently done manually.

1. On the master (generally `pi01`), run `sudo kubeadm init --apiserver-advertise-address {master-ip-address}`
1. Run the commands indicated after setup is complete
1. Install the weave CNI with `kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"`
1. Run the `kubeadmin join` command on the remaining pis

## Todo

* Automatically create tags on managed instance after registration
