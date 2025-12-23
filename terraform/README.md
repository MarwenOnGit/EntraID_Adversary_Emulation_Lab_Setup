Terraform setup for launching a single EC2 instance (red-team lab).

Quick start

1. Ensure AWS CLI is configured (you already completed this).

2. Copy example tfvars and edit if needed:

   cp terraform.tfvars.example terraform.tfvars

3. Initialize Terraform and view a plan:

   terraform init
   terraform plan

4. Apply to create the instance:

   terraform apply

Notes

- Credentials: Terraform will use the standard AWS credential resolution (env vars, AWS profile, shared credentials file).
- Consider moving state to a remote backend (S3 + DynamoDB) for team collaboration.
- Use `AWS_PROFILE` environment variable if you configured multiple profiles.
