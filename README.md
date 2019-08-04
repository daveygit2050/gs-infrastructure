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

### Master configuration

1. On the master (generally `pi01`), run `sudo kubeadm init --apiserver-advertise-address {master-ip-address}`
1. Run the commands indicated after setup is complete
1. Install the weave CNI with `kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"`
1. Install and configure [MetalLB](https://metallb.universe.tf/tutorial/layer2/), using `./kube/config/metallb/config.yaml` for the config map

### Node configuration

Run the `kubeadmin join` command on the remaining pis. It can be generated on the master with `kubeadm token create --print-join-command`.

### Service configuration

Before running the below, copy the contents of the `kube` folder to the home directory on the master.

#### Jenkins

The jenkins master needs to be locked to a specific node so that configuration can be persisted to disk. 

1. Run `kubectl label nodes {node} gs-type=jenkins-master`
1. Run `kubectl apply -f ~/kube/manifests/jenkins.yaml`
1. Use `kubectl get services --namespace jenkins` to find the load balancer address (the `EXTERNAL_IP`)

#### Pi-hole

##### Initial setup

Firstly, create a file in `~/kube/config/pihole/` called `admin-password`, that contains the desired password for the pihole admin endpoint. Modifiy the `gs-int.list` file with the appropriate record configuration.

1. Run `kubectl create namespace pihole`
1. Set the working directory to `~/kube/config/pihole/`
1. Run `kubectl create secret generic pihole-secrets --from-file admin-password -n pihole`
1. Run `kubectl create configmap gs-int --from-file 02-gs-int.conf --from-file gs-int.list -n pihole`
1. Run `kubectl apply -f ~/kube/manifests/pihole.yaml`

##### Updating gs.int records

The below process involves replaceing the existing config map with a new one that includes the desired changes. Once the new config map is in place, the pod needs to be recycled for the new file to be deployed. This results in a small period of down time for the service.

1. Make required changes to `kube/config/pihole/gs-int.list`
1. Upload amended file to `~/kube/config/pihole/`
1. Run `kubectl delete configmaps/gs-int --namespace pihole`
1. Run `kubectl create configmap gs-int --from-file ~/kube/config/pihole/02-gs-int.conf --from-file ~/kube/config/pihole/gs-int.list --namespace pihole`
1. Run `kubectl get pods --namespace pihole | grep pihole | awk '{print $1}' | xargs kubectl delete pod --namespace pihole`

## Todo

* Automatically create tags on managed instance after registration
