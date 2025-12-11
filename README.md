# Ansible Azure - Gitea Demo

Ansible automation for deploying Gitea on Azure infrastructure with MySQL Flexible Server.

## ��� Overview

This repository contains Ansible playbooks and roles for automating the deployment of Gitea on Azure Virtual Machines. It's designed to work in conjunction with the [tf-az-infra-demoGitea](https://github.com/andreaendigital/tf-az-infra-demoGitea) Terraform repository.

### Features

- ✅ Automated Gitea installation and configuration
- ✅ Azure MySQL Flexible Server integration
- ✅ Systemd service management
- ✅ Idempotent playbooks (safe to run multiple times)
- ✅ Dynamic inventory generation from Terraform outputs
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
│  └──────────────┘         └──────────────────┘ │
│         │                                        │
│         ▼                                        │
│  ┌──────────────┐                               │
│  │ Load Balancer│                               │
│  │  :80 → :3000 │                               │
│  └──────────────┘                               │
└─────────────────────────────────────────────────┘
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

### 1. Clone the Repository

\`\`\`bash
git clone git@github.com:andreaendigital/ansible-az-demoGitea.git
cd ansible-az-demoGitea
\`\`\`

### 2. Configure Variables (Optional)

If you want to pre-configure an admin user:

\`\`\`bash
cp group_vars/all.yml.example group_vars/all.yml
vi group_vars/all.yml  # Edit admin credentials
\`\`\`

**Important:** Change the default password!

\`\`\`yaml
gitea_admin_username: "admin"
gitea_admin_password: "YourSecurePassword123!"
gitea_admin_email: "admin@yourdomain.com"
\`\`\`

For production, encrypt the file:

\`\`\`bash
ansible-vault encrypt group_vars/all.yml
\`\`\`

### 3. Generate Inventory from Terraform

\`\`\`bash
./generate_inventory.sh
\`\`\`

### 4. Run the Playbook

\`\`\`bash
ansible-playbook -i inventory.ini playbook.yml
\`\`\`

## ��� Project Structure

\`\`\`
ansible-az-demoGitea/
├── ansible.cfg
├── playbook.yml
├── inventory.ini
├── generate_inventory.sh
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
\`\`\`

## ��� Related Repositories

- [tf-az-infra-demoGitea](https://github.com/andreaendigital/tf-az-infra-demoGitea) - Terraform infrastructure for Azure
- [tf-infra-demoGitea](https://github.com/andreaendigital/tf-infra-demoGitea) - Terraform infrastructure for AWS
- [ansible-demoGitea](https://github.com/andreaendigital/ansible-demoGitea) - Ansible for AWS

## ��� Development

### Commit Convention

All commits use \`DEMO-22\` prefix for Jira integration.

---

**Note:** This is the Azure version of the Gitea deployment automation.
