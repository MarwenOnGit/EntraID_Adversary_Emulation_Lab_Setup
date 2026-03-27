# Terraform – Red Team EC2 in eu-west-3

Automatically generates SSH keys, creates AWS key pair, and provisions Ubuntu 22.04 EC2 instance.

## Files

- **`provider.tf`** — AWS, TLS, local providers
- **`variables.tf`** — aws_region (eu-west-3), instance_type (t3.small), ami_id, ssh paths
- **`main.tf`** — TLS key generation, AWS key pair, EC2 + security group
- **`iam.tf`** — IAM role and instance profile for SSM
- **`outputs.tf`** — instance_id, public_ip, private_ip, ssh_command, ansible_inventory
- **`generate_ansible_inventory.sh`** — Auto-generates ../ansible/inventory.ini
- **`keys/`** — Terraform saves id_rsa (0600) and id_rsa.pub here (gitignored)

## Quick Start

```bash
aws sts get-caller-identity  # Verify AWS CLI
terraform init
terraform apply -auto-approve
./generate_ansible_inventory.sh  # Creates ../ansible/inventory.ini
ls -l keys/id_rsa  # Verify private key (should be 0600)
```

## How It Works

**main.tf** does the heavy lifting:
1. `tls_private_key` — generates 4096-bit RSA key pair
2. `aws_key_pair` — imports public key into AWS
3. `local_sensitive_file` — saves private key to `keys/id_rsa` (0600 perms)
4. `local_file` — saves public key to `keys/id_rsa.pub`
5. `aws_instance` — creates EC2 with key pair attached

## Manual SSH

```bash
ssh -i terraform/keys/id_rsa ubuntu@<public_ip>
```

## Common Commands

```bash
terraform output                    # Show all outputs
terraform output -raw public_ip     # Get instance IP
terraform destroy -auto-approve     # Tear down
```

## Defaults

| Variable | Default |
|----------|---------|
| `aws_region` | eu-west-3 |
| `instance_type` | t3.small |
| `ssh_user` | ubuntu |

## Troubleshooting

| Issue | Fix |
|-------|-----|
| AWS credentials missing | Set AWS_PROFILE or AWS_ACCESS_KEY_ID/SECRET_ACCESS_KEY |
| SSH key permission denied | Verify keys/id_rsa exists and has 0600 perms |
| Instance fails to launch | Check security group allows SSH (port 22) |

## Next

Run `./generate_ansible_inventory.sh` then execute Ansible playbooks from `../ansible/`.
