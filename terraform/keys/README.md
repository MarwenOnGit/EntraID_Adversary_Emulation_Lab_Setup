Place your SSH private/public key pair here if you want Terraform/Ansible to use repo-local keys.

Files expected (example):
- `id_rsa`         (private key)  -> DO NOT COMMIT
- `id_rsa.pub`     (public key)   -> can be used by Terraform to import an EC2 key pair

Security notes:
- Never commit `id_rsa` (private key) to git. The repository `.gitignore` contains `terraform/keys/*` to help prevent accidental commits.
- If you want Terraform to import the public key and use it for instances, set `create_key_pair = true` in `terraform.tfvars` and ensure `public_key_path` points to `terraform/keys/id_rsa.pub`.

Example:
```bash
# generate a keypair in the repo-local folder (control machine)
ssh-keygen -t rsa -b 4096 -f terraform/keys/id_rsa -N ""
chmod 600 terraform/keys/id_rsa
```