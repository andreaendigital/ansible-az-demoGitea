#!/bin/bash
# generate_inventory.sh - Genera inventory.ini automáticamente usando outputs de Terraform
# Uso: ./generate_inventory.sh /ruta/al/terraform/infra

set -e

if [ -z "$1" ]; then
  echo "Uso: $0 /ruta/al/terraform/infra"
  exit 1
fi

TF_DIR="$1"
cd "$TF_DIR"

# Obtener outputs de Terraform en JSON
tfout=$(terraform output -json)

# Extraer valores necesarios
VM_PUBLIC_IP=$(echo "$tfout" | jq -r '.vm_public_ip.value')
MYSQL_VM_PRIVATE_IP=$(echo "$tfout" | jq -r '.mysql_vm_private_ip.value')
REPLICATION_USER=$(echo "$tfout" | jq -r '.replication_user.value')
REPLICATION_PASSWORD=$(echo "$tfout" | jq -r '.replication_password.value')
MYSQL_DB_NAME=$(echo "$tfout" | jq -r '.mysql_db_name.value')

# Volver al directorio original
cd - > /dev/null

# Generar inventory.ini
echo "[azureGitea]
vm-instance ansible_host=$VM_PUBLIC_IP ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/azure-gitea-key.pem

[mysql-replica]
mysql-replica-vm ansible_host=$MYSQL_VM_PRIVATE_IP ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/azure-gitea-key.pem

[mysql-replica:vars]
gitea_replica_user=$REPLICATION_USER
gitea_replica_password=$REPLICATION_PASSWORD
gitea_replica_db=$MYSQL_DB_NAME
mysql_server_id=2
" > inventory.ini

echo "Archivo inventory.ini generado correctamente."
