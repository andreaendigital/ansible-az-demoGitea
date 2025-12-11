#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Navigate to Terraform infra directory
# Jenkins workspace structure: workspace/tf-az-infra-demoGitea/infra/
cd "$SCRIPT_DIR/../tf-az-infra-demoGitea/infra" || exit 1

terraform init -reconfigure -backend=true

# Run terraform output to get VM IP and MySQL credentials
VM_PUBLIC_IP=$(terraform output -raw vm_public_ip)
MYSQL_FQDN=$(terraform output -raw mysql_server_fqdn)
MYSQL_HOST=$(terraform output -raw mysql_server_host)
MYSQL_USERNAME=$(terraform output -raw mysql_admin_username)
MYSQL_PASSWORD=$(terraform output -raw mysql_admin_password)
MYSQL_DBNAME=$(terraform output -raw mysql_database_name)

# Verify that a valid IP address was obtained
if [[ -z "$VM_PUBLIC_IP" ]]; then
  echo "Could not obtain the public IP address of the Azure VM"
  exit 1
fi

# Return to ansible directory
cd "$SCRIPT_DIR" || exit 1

# Generate the inventory.ini file for Ansible with MySQL variables
cat <<EOF > inventory.ini
[azureGitea]
vm-instance ansible_host=$VM_PUBLIC_IP ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/azure-gitea-key.pem

[azureGitea:vars]
mysql_fqdn=$MYSQL_FQDN
mysql_host=$MYSQL_HOST
mysql_username=$MYSQL_USERNAME
mysql_password=$MYSQL_PASSWORD
mysql_dbname=$MYSQL_DBNAME
EOF

echo "inventory.ini file generated with VM IP: $VM_PUBLIC_IP"
echo "MySQL Flexible Server configured: $MYSQL_FQDN"
