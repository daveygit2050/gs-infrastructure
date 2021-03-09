#!/usr/bin/env bash
set -euo pipefail

echo "Running Ansible playbook."
ansible-playbook --inventory ansible/inventories/pis ansible/pis.yml
