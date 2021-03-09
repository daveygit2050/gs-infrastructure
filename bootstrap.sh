#!/usr/bin/env bash
set -euo pipefail

PI_HOSTNAME=$1
PI_IP_ADDRESS=$2

if [ -z ${PI_HOSTNAME} ] || [ -z ${PI_IP_ADDRESS} ]; then
  echo "Usage - boostrap.sh [pi-hostname] [pi-ip-address]"
  exit 1
fi

cd ansible

echo "Bootstrapping ${PI_HOSTNAME} on ${PI_IP_ADDRESS}."

echo "Updating Ansible inventory."
echo "${PI_HOSTNAME} ansible_host=${PI_IP_ADDRESS}" >> inventories/pis

echo "Generating SSM activation."
SSM_RESULT=`aws ssm create-activation --default-instance-name ${PI_HOSTNAME} --iam-role ssm-service-role --registration-limit 1 --region eu-west-1 --output json`
ACTIVATION_ID=`echo ${SSM_RESULT} | jq '.ActivationId'`
ACTIVATION_CODE=`echo ${SSM_RESULT} | jq '.ActivationCode'`

echo "Running Ansible playbook."
ansible-playbook --inventory inventories/pis --user ubuntu --ask-pass --limit ${PI_HOSTNAME} --extra-vars "activation_code=${ACTIVATION_CODE} activation_id=${ACTIVATION_ID}" --ask-become-pass pis-initial.yml
