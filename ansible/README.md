# Ansible Setup - Red Team Infrastructure Automation

## Overview

Ansible playbooks for automated configuration and deployment of red-team infrastructure on EC2 instances created by Terraform.

## Files

- **`ansible.cfg`** — Global Ansible configuration (SSH, logging, roles path)
- **`inventory.ini.example`** — Example inventory template
- **`playbooks/base-setup.yml`** — System hardening and essential tools installation
- **`playbooks/deploy-evilginx.yml`** — Build and deploy Evilginx2 phishing framework
- **`playbooks/site.yml`** — Master playbook orchestrating all configurations

## Prerequisites

```bash
# Install Ansible on your control machine
pip3 install ansible

# Ensure SSH access to instances
# Copy your key to ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

# Test connectivity
ansible -i inventory.ini -u ec2-user -m ping redteam
```

## Quick Start

### 1. Create Terraform Infrastructure

```bash
cd ../terraform
terraform apply -auto-approve
INSTANCE_IP=$(terraform output -raw public_ip)
```

### 2. Populate Ansible Inventory

```bash
cd ../ansible
cp inventory.ini.example inventory.ini

# Edit inventory.ini and add your instance(s):
cat > inventory.ini << EOF
[redteam]
redteam-01 ansible_host=$INSTANCE_IP ansible_user=ec2-user
EOF
```

Alternatively, you can auto-generate the inventory from Terraform outputs (recommended when running Terraform from this repo):

```bash
# Run from the `terraform/` directory in the repo root
./generate_ansible_inventory.sh
```
This writes `ansible/inventory.ini` when Terraform outputs are present.

### 3. Test SSH Connectivity

```bash
# Wait for instance to be ready (30-60 seconds)
sleep 30

# Test SSH connectivity
ssh -i ~/.ssh/id_rsa ec2-user@$INSTANCE_IP "echo ready"

# Or use Ansible ping
ansible redteam -m ping
```

### 4. Run Playbooks

**Base Setup Only:**
```bash
ansible-playbook playbooks/base-setup.yml
```

**Deploy Evilginx2:**
```bash
ansible-playbook playbooks/deploy-evilginx.yml
```

**Everything (Recommended):**
```bash
ansible-playbook playbooks/site.yml
```

## Playbook Details

### base-setup.yml
- Updates all system packages
- Installs essential tools (git, curl, wget, nmap, python3, etc.)
- Creates `redteam` user with sudo NOPASSWD access
- Configures SSH key authentication
- Disables SELinux (optional for lab)
- Sets up logging directory

**Usage:**
```bash
ansible-playbook playbooks/base-setup.yml -t base
```

### deploy-evilginx.yml
- Installs Go (if not present)
- Clones Evilginx2 repository
- Builds Evilginx2 from source
- Copies binary to `/usr/local/bin/`
- Creates configuration directories

**Usage:**
```bash
ansible-playbook playbooks/deploy-evilginx.yml -t evilginx
```

### site.yml
- Orchestrates base-setup and deploy-evilginx
- Displays setup summary with system info

**Usage:**
```bash
ansible-playbook playbooks/site.yml
```

## Automation: Terraform + Ansible Integration

Create an automation script `deploy.sh`:

```bash
#!/bin/bash
set -e

echo "🔄 Creating infrastructure with Terraform..."
cd terraform
terraform apply -auto-approve
INSTANCE_IP=$(terraform output -raw public_ip)
cd ../ansible

echo "⏳ Waiting for instance to be ready (30 seconds)..."
sleep 30

echo "🔑 Testing SSH connectivity..."
until ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=5 ec2-user@$INSTANCE_IP "echo ready" > /dev/null 2>&1; do
  echo "  ⏳ SSH not ready yet, retrying..."
  sleep 5
done

echo "📋 Generating inventory..."
cat > inventory.ini << EOF
[redteam]
redteam-01 ansible_host=$INSTANCE_IP ansible_user=ec2-user
EOF

echo "🚀 Running Ansible playbooks..."
ansible-playbook playbooks/site.yml

echo "✅ Setup complete!"
echo "📍 Instance IP: $INSTANCE_IP"
echo "🔐 SSH: ssh -i ~/.ssh/id_rsa ec2-user@$INSTANCE_IP"
```

Make executable and run:
```bash
chmod +x deploy.sh
./deploy.sh
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| SSH connection refused | Instance still starting; wait 30-60 seconds |
| Permission denied (publickey) | Ensure SSH key path is correct and permissions are 600 |
| Host key checking error | Set `host_key_checking = False` in `ansible.cfg` |
| Module not found | Install Python modules on target: `yum install python3-*` |
| Sudo password required | Ensure `become_ask_pass = False` in `ansible.cfg` |

## Security Best Practices

1. **SSH Keys** — Keep private keys secure; use `chmod 600`
2. **Inventory** — Don't commit `inventory.ini` with real IPs to version control
3. **Credentials** — Use Ansible Vault for sensitive data:
   ```bash
   ansible-vault create secrets.yml
   ansible-playbook playbooks/site.yml --ask-vault-pass
   ```
4. **Firewall** — Restrict EC2 security group SSH (port 22) to your IP
5. **IAM** — Use least-privilege IAM user for Terraform

## Next Steps

1. Create additional playbooks for:
   - C2 server setup (Metasploit, Covenant, etc.)
   - Logging and monitoring
   - Custom red-team tools
   
2. Add roles for modular playbook design:
   ```bash
   ansible-galaxy init roles/c2-server
   ```

3. Implement dynamic inventory using AWS EC2 plugin
4. Set up automated testing with Molecule

## References

- [Ansible Documentation](https://docs.ansible.com/)
- [Evilginx2 GitHub](https://github.com/kgretzky/evilginx2)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
