#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "Uso: $0 /ruta/al/terraform/infra"
  exit 1
fi

TF_DIR="$1"
cd "$TF_DIR"

tfout=$(terraform output -json)

VM_PUBLIC_IP=$(echo "$tfout" | jq -r '.vm_public_ip.value')
MYSQL_VM_PRIVATE_IP=$(echo "$tfout" | jq -r '.mysql_vm_private_ip.value')

cd - > /dev/null

cat > inventory.ini <<EOF
[azureGitea]
vm-instance ansible_host=$VM_PUBLIC_IP ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/azure-gitea-key.pem

[azureGitea:vars]
mysql_host=$MYSQL_VM_PRIVATE_IP

[mysql-replica]
mysql-replica-vm ansible_host=$MYSQL_VM_PRIVATE_IP ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/azure-gitea-key.pem

[mysql-replica:vars]
gitea_replica_user=gitea_replica
gitea_replica_password=ChangeThisReplicaPassword!
gitea_replica_db=gitea_replica_db
mysql_server_id=2
EOF
