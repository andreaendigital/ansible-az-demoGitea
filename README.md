# Ansible Azure - Gitea Demo

Ansible automation for deploying Gitea on Azure infrastructure with MySQL Flexible Server.

## Modular MySQL Replica/Failover Support

This repository now supports deploying a dedicated MySQL VM as a read replica, ready for future integration as a failover target (e.g., AWS RDS replica scenario). The playbook is modular:

- `roles/mysql-replica`: Installs and configures MySQL as a replica for Gitea, with clear variables for replication and failover.
- `inventory.ini`: Includes both the Gitea VM and a MySQL replica VM, with variables for each.
- Easily switch Gitea to use the replica DB by updating connection variables.

**Purpose:**
You can test the full stack, but later keep only the DB as a replica. When AWS fails over, deploy the app and connect to the active replica DB.

**Key variables:**

- `gitea_replica_db`, `gitea_replica_user`, `gitea_replica_password`, `mysql_server_id`, etc.

See `roles/mysql-replica/` and `group_vars/mysql-replica.yml.example` for details.

## ��� Overview

This repository contains Ansible playbooks and roles for automating the deployment of Gitea on Azure Virtual Machines. It's designed to work in conjunction with the [tf-az-infra-demoGitea](https://github.com/andreaendigital/tf-az-infra-demoGitea) Terraform repository.

### Features

- ✅ Automated Gitea installation and configuration
- ✅ Azure MySQL Flexible Server integration
- ✅ Systemd service management
- ✅ Idempotent playbooks (safe to run multiple times)
- ✅ Static IP configuration (no dynamic inventory needed)
- ✅ Optional admin user pre-configuration
- ✅ Production-ready security settings

## ���️ Architecture

```
┌─────────────────────────────────────────────────┐
│           Azure Infrastructure                   │
│  (Managed by tf-az-infra-demoGitea)             │
│                                                  │
│  ┌──────────────┐         ┌──────────────────┐ │
│  │  Azure VM    │────────▶│  MySQL Flexible  │ │
│  │  (Ubuntu)    │         │  Server          │ │
│  │              │         │  (B_Standard_B1ms│ │
│  │  Gitea:3000  │         │   20GB)          │ │
│  │              │         └──────────────────┘ │
│  │ Static       │                               │
│  │ Public IP    │         ┌──────────────────┐ │
│  └──────────────┘────────▶│ Load Balancer    │ │
│        ↑                  │  (Port 80→3000)  │ │
│        │                  └──────────────────┘ │
│        │ SSH (Port 22)                          │
└────────┼────────────────────────────────────────┘
         │
         ▼
    ┌─────────────┐
    │ Ansible     │
    │ Playbook    │
    └─────────────┘
```

## ��� Prerequisites

### Required Software

- Ansible >= 2.9
- Python >= 3.6
- SSH client
- Access to Azure infrastructure (deployed via Terraform)

### Required Access

- SSH private key for Azure VM access
- Azure infrastructure must be deployed first using Terraform
- Network connectivity to Azure resources

## ��� Quick Start

### 1. Deploy Azure Infrastructure

First, deploy the Azure infrastructure using Terraform:

```bash
cd ../tf-az-infra-demoGitea/infra
terraform init
terraform apply
```

### 2. Get Static IP Address

The VM has a **static public IP** that won't change:

```bash
terraform output -raw vm_public_ip
# Example output: 52.x.x.x
```

Also get MySQL VM IP:

```bash
terraform output -raw mysql_vm_private_ip
```

### 3. Update Inventory File

Edit `inventory.ini` and replace placeholders with actual values:

```bash
cd ../ansible-az-demoGitea
vi inventory.ini
```

Replace:

- `<VM_PUBLIC_IP>` with the static public IP from step 2
- `<MYSQL_VM_PRIVATE_IP>` with MySQL VM private IP

**Note:** Since the IP is static, you only need to do this **once**.

Alternatively, use the automated script:

```bash
./generate_inventory.sh ../tf-az-infra-demoGitea/infra
```

### 4. Configure Variables (Optional)

If you want to pre-configure an admin user:

```bash
cp group_vars/all.yml.example group_vars/all.yml
vi group_vars/all.yml
```

Update admin credentials:

```yaml
gitea_admin_username: "admin"
gitea_admin_password: "YourSecurePassword123!"
gitea_admin_email: "admin@yourdomain.com"
```

For production, encrypt the file:

```bash
ansible-vault encrypt group_vars/all.yml
```

### 5. Run the Playbook

**IMPORTANT:** Pass `mysql_root_password` via `--extra-vars` for security:

```bash
ansible-playbook -i inventory.ini playbook.yml --extra-vars "mysql_root_password=YOUR_SECURE_PASSWORD"
```

With vault-encrypted variables:

```bash
ansible-playbook -i inventory.ini playbook.yml --ask-vault-pass --extra-vars "mysql_root_password=YOUR_SECURE_PASSWORD"
```

**Note:** The MySQL root password is NOT stored in the inventory for security. It must be passed as an extra variable.

## ��� Project Structure

```
ansible-az-demoGitea/
├── ansible.cfg
├── playbook.yml
├── inventory.ini               # Static inventory (update once)
├── group_vars/
│   └── all.yml.example
├── roles/
│   └── deploy/
│       ├── tasks/
│       │   └── main.yml
│       └── templates/
│           ├── app.ini.j2
│           └── gitea.service
└── .github/
    └── pull_request_template.md
```

## ��� Configuration

### Gitea Version

Default version is `1.25.2`. To change, update `group_vars/all.yml`:

```yaml
gitea_version: "1.25.2"
```

### Admin User Configuration

Two options:

#### Option 1: Pre-configured Admin

```yaml
gitea_admin_username: "admin"
gitea_admin_password: "SecurePassword123!"
gitea_admin_email: "admin@example.com"
```

#### Option 2: First User Becomes Admin

Omit the `gitea_admin_*` variables. The first user to register becomes admin.

## ��� Key Differences from AWS Version

| Aspect              | AWS (ANSIBLE-DEMOGITEA)           | Azure (This Repo)           |
| ------------------- | --------------------------------- | --------------------------- |
| **Inventory**       | Dynamic (`generate_inventory.sh`) | Static (one-time setup)     |
| **IP Type**         | Dynamic (changes each deploy)     | **Static** (never changes)  |
| **Host Group**      | `infraGitea`                      | `azureGitea`                |
| **SSH User**        | `ec2-user`                        | `azureuser`                 |
| **Package Manager** | `yum` (Amazon Linux)              | `apt` (Ubuntu)              |
| **Database**        | AWS RDS                           | Azure MySQL Flexible Server |

## ��� Security Best Practices

1. **Never commit unencrypted credentials**

   ```bash
   ansible-vault encrypt group_vars/all.yml
   ```

2. **Use strong passwords**

   - Minimum 12 characters
   - Mix of uppercase, lowercase, numbers, symbols

3. **Restrict SSH access**

   - NSG rule limits SSH to your IP (`admin_source_ip`)
   - SSH keys only (no passwords)

4. **Use Azure Key Vault for production**
   - Store secrets centrally
   - Reference via environment variables

## ��� Testing

### Check Syntax

```bash
ansible-playbook playbook.yml --syntax-check
```

### Dry Run

```bash
ansible-playbook -i inventory.ini playbook.yml --check
```

### Verify Connection

```bash
ansible -i inventory.ini all -m ping
```

## ��� Post-Deployment Verification

After successful deployment:

1. **Check Gitea service:**

   ```bash
   ssh azureuser@<VM_PUBLIC_IP> "sudo systemctl status gitea"
   ```

2. **Access Gitea web interface:**

   ```
   http://<LOAD_BALANCER_IP>
   ```

3. **Check logs:**
   ```bash
   ssh azureuser@<VM_PUBLIC_IP> "sudo journalctl -u gitea -f"
   ```

## ��� Updating Gitea

To update:

1. Update `gitea_version` in `group_vars/all.yml`
2. Re-run the playbook (idempotent):
   ```bash
   ansible-playbook -i inventory.ini playbook.yml
   ```

## ��� Troubleshooting

### SSH Connection Failed

```bash
# Check SSH key permissions
chmod 600 ~/.ssh/azure-gitea-key.pem

# Test connection
ssh -i ~/.ssh/azure-gitea-key.pem azureuser@<VM_PUBLIC_IP>
```

### MySQL Connection Failed

```bash
# Test from VM
ssh azureuser@<VM_PUBLIC_IP>
telnet <MYSQL_HOST> 3306

# Verify NSG allows MySQL traffic
```

### Gitea Won't Start

```bash
# Check logs
sudo journalctl -u gitea -n 100 --no-pager
sudo tail -f /var/lib/gitea/log/gitea.log

# Run doctor
sudo /usr/local/bin/gitea doctor -c /etc/gitea/app.ini
```

## ���️ CI/CD Integration

### Jenkins Pipeline Example

```groovy
pipeline {
    agent any

    stages {
        stage('Deploy Infrastructure') {
            steps {
                dir('tf-az-infra-demoGitea/infra') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Get Outputs') {
            steps {
                dir('tf-az-infra-demoGitea/infra') {
                    script {
                        env.VM_IP = sh(
                            script: 'terraform output -raw vm_public_ip',
                            returnStdout: true
                        ).trim()
                    }
                }
            }
        }

        stage('Update Inventory') {
            steps {
                dir('ansible-az-demoGitea') {
                    sh """
                        sed -i 's/<VM_PUBLIC_IP>/${env.VM_IP}/g' inventory.ini
                    """
                }
            }
        }

        stage('Deploy Gitea') {
            steps {
                dir('ansible-az-demoGitea') {
                    sh 'ansible-playbook -i inventory.ini playbook.yml'
                }
            }
        }
    }
}
```

## ��� Related Repositories

- [tf-az-infra-demoGitea](https://github.com/andreaendigital/tf-az-infra-demoGitea) - Terraform for Azure
- [tf-infra-demoGitea](https://github.com/andreaendigital/tf-infra-demoGitea) - Terraform for AWS
- [ansible-demoGitea](https://github.com/andreaendigital/ansible-demoGitea) - Ansible for AWS

## ��� Development

### Commit Convention

All commits use `DEMO-22` prefix for Jira integration:

```bash
git commit -m "DEMO-22: Add health check for Gitea service"
```

### Branch Strategy

- `main` - Production-ready code
- `DEMO-22-*` - Feature branches

---

**Note:** This is the Azure version optimized for **static IP** deployment. No dynamic inventory generation needed.
