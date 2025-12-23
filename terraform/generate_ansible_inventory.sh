#!/usr/bin/env bash
set -e

# Generate Ansible inventory from Terraform outputs (if available)
# Usage: run from /terraform directory

OUTFILE="../ansible/inventory.ini"

if terraform output -raw ansible_inventory > /dev/null 2>&1; then
  # Get the raw output and convert the key path to be relative to ansible/ directory
  INVENTORY=$(terraform output -raw ansible_inventory)
  # Replace "terraform/keys/id_rsa" with "../terraform/keys/id_rsa"
  INVENTORY=$(echo "$INVENTORY" | sed 's|ansible_ssh_private_key_file=terraform/keys/id_rsa|ansible_ssh_private_key_file=../terraform/keys/id_rsa|g')
  
  # Write with group header
  cat > "$OUTFILE" <<EOF
[redteam]
$INVENTORY

[redteam:vars]
ansible_python_interpreter=/usr/bin/python3
EOF
  echo "Wrote inventory to $OUTFILE"
  cat "$OUTFILE"
  exit 0
fi

# Fallback: try to get public_ip and ssh_user
PUBLIC_IP=$(terraform output -raw public_ip 2>/dev/null || true)
SSH_USER=$(terraform output -raw ssh_user 2>/dev/null || echo "ubuntu")

if [ -n "$PUBLIC_IP" ]; then
  cat > "$OUTFILE" <<EOF
[redteam]
redteam-01 ansible_host=${PUBLIC_IP} ansible_user=${SSH_USER} ansible_ssh_private_key_file=../terraform/keys/id_rsa

[redteam:vars]
ansible_python_interpreter=/usr/bin/python3
EOF
  echo "Wrote fallback inventory to $OUTFILE"
  cat "$OUTFILE"
  exit 0
fi

echo "Couldn't obtain Terraform outputs."
echo "Either run 'terraform apply' to create resources, or manually create 'ansible/inventory.ini' with the instance IP."
echo "Example content (replace <IP>):"
echo "[redteam]"
echo "redteam-01 ansible_host=<IP> ansible_user=ubuntu ansible_ssh_private_key_file=../terraform/keys/id_rsa"
exit 1
