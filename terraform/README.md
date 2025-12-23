# Terraform Setup – Red Team EC2 Infrastructure

This directory contains Terraform configuration to provision and manage a single EC2 instance for red-team lab operations in AWS `eu-west-3`.

## Files

- **`provider.tf`** — AWS provider configuration (region, version constraints)
- **`variables.tf`** — Input variables (aws_region, instance_type, ami_id, key_name, ssh_private_key_path, ssh_user)
- **`main.tf`** — EC2 instance and security group resources
- **`iam.tf`** — IAM role and instance profile for EC2 Systems Manager (SSM)
- **`outputs.tf`** — Terraform outputs (instance IPs, SSH info, Ansible inventory)
- **`terraform.tfvars.example`** — Example variable overrides
- **`generate_ansible_inventory.sh`** — Script to auto-generate `../ansible/inventory.ini` from Terraform outputs
- **`keys/`** — Directory for repo-local SSH keys (gitignored; see `keys/README.md`)

## Quick Start

1. **Ensure AWS CLI is configured:**
   ```bash
   aws sts get-caller-identity
   ```

2. **Copy and customize variables (optional):**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars to override defaults if needed
   ```

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Plan and review:**
   ```bash
   terraform plan
   ```

5. **Apply to provision:**
   ```bash
   terraform apply -auto-approve
   ```

## SSH Key Setup

The configuration uses a repo-local SSH key path: `terraform/keys/id_rsa`

**Option 1: Import existing EC2 key pair**
```bash
cp ~/Downloads/your-key.pem ./keys/id_rsa
chmod 600 ./keys/id_rsa
echo 'key_name = "your-key"' >> terraform.tfvars
```

**Option 2: Create via Terraform** (uncomment in `main.tf`)
- Terraform will generate a new RSA key and save the private key to `keys/id_rsa`

**Option 3: Use AWS Systems Manager (SSM)**
- If IAM role is configured, use `aws ssm start-session --target <instance-id> --region eu-west-3`

## Terraform Workflow

```bash
terraform output                    # Show all outputs
terraform output -raw public_ip     # Show just the public IP
terraform output -json              # JSON format

./generate_ansible_inventory.sh     # Auto-generate Ansible inventory

terraform destroy                   # Remove resources
```

## Configuration Details

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `eu-west-3` | AWS region (Ireland) |
| `instance_type` | `t3.small` | EC2 instance type |
| `ami_id` | Ubuntu 22.04 LTS | Amazon Machine Image |
| `key_name` | *(required)* | EC2 key pair name |
| `ssh_private_key_path` | `terraform/keys/id_rsa` | Private key for Ansible |
| `ssh_user` | `ubuntu` | SSH username |

## AWS Credentials

Terraform uses standard AWS credential resolution:
1. Environment variables: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
2. AWS profile: `export AWS_PROFILE=profile-name`
3. Shared credentials file: `~/.aws/credentials`

## Next Steps

1. Run `terraform apply` to provision the instance
2. Use `./generate_ansible_inventory.sh` to create Ansible inventory
3. Run Ansible playbooks from `../ansible/` directory
4. See `../ansible/README.md` for playbook usage

## References

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Terraform State Management](https://www.terraform.io/language/state)
