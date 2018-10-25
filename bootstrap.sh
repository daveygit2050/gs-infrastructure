#!/usr/bin/env bash
set -e

PI_HOSTNAME=$1
PI_IP_ADDRESS=$2

if [ -z ${PI_HOSTNAME} ] || [ -z ${PI_IP_ADDRESS} ]; then
  echo "Usage - boostrap.sh [pi-hostname] [pi-ip-address]"
  exit 1
fi

cd ansible

echo "Updating Ansible inventory"
sed -n -e "/^${PI_HOSTNAME} ansible_host=/!p" -e "\$a${PI_HOSTNAME} ansible_host=${PI_IP_ADDRESS}" -i inventories/pis

echo "Generating SSM activation"
SSM_RESULT=`aws ssm create-activation --default-instance-name ${PI_HOSTNAME} --iam-role ssm-service-role --registration-limit 1 --region eu-west-1 --output json`
ACTIVATION_ID=`echo ${SSM_RESULT} | jq '.ActivationId'`
ACTIVATION_CODE=`echo ${SSM_RESULT} | jq '.ActivationCode'`

echo "Running Ansible playbook"
ansible-playbook -i inventories/pis -u pi -k -l ${PI_HOSTNAME} --extra-vars "activation_code=${ACTIVATION_CODE} activation_id=${ACTIVATION_ID}" pis.yml
