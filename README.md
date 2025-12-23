# Entra ID & Hybrid Adversary Emulation Lab  
**Focus: Adversary-in-the-Middle (AiTM) Phishing against Microsoft 365 / Entra ID**  
*School Year-End Project – December 2025*

**Status:** Educational laboratory setup – NO real users or production environments were targeted.  
**Purpose:** Demonstrate modern cloud identity attack techniques and highlight detection/prevention controls.

⚠️ **DISCLAIMER**  
This repository contains documentation, diagrams, and educational write-ups only.  
No phishing tools, phishlets, binaries, or malicious code are included.  
All hands-on work was performed in an isolated lab environment for authorized adversary emulation and research purposes only.

## Project Overview

This project simulates real-world phishing attacks that target Microsoft Entra ID (formerly Azure AD) and Microsoft 365 services, with a focus on:

- **Adversary-in-the-Middle (AiTM)** techniques to bypass MFA
- Session/token theft (access tokens, refresh tokens, cookies)
- Post-exploitation pivoting to Entra ID / Microsoft Graph API
- Relevance to hybrid environments (synced identities via Entra Connect)
- Pivoting from initial Entra ID access to full on-prem domain(s) compromise 

The primary technique emulated is **AiTM phishing**, which allows attackers to relay authentication in real time and capture session tokens even when strong MFA is in place.

MITRE ATT&CK techniques covered:
- T1566.002 – Phishing: Spearphishing Link
- T1555 – Credentials from Password Stores (session tokens)
- T1078.004 – Valid Accounts: Cloud Accounts
- T1528 – Steal Application Access Token

## Lab Architecture (High-Level)

- **Attacker Machine**: Local Ubuntu VM running a man-in-the-middle phishing proxy
- **Victim Simulation**: Windows 10/11 machine or browser on separate profile (hybrid-joined optional)
- **Target Identity Provider**: Microsoft Entra ID (free/trial tenant used for testing)
- **AWS Infrastructure**: Terraform-provisioned EC2 instance in `eu-west-3` with Ansible-managed configuration
- **All components isolated** – no external exposure

## Infrastructure Setup (Terraform + Ansible)

This repository includes Infrastructure-as-Code (IaC) automation to provision and configure a red-team EC2 instance.

### Quick Start

1. **Provision infrastructure with Terraform:**
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply -auto-approve
   ```

2. **Generate Ansible inventory from Terraform outputs:**
   ```bash
   ./generate_ansible_inventory.sh
   cd ../ansible
   ```

3. **Test SSH connectivity:**
   ```bash
   ansible -i inventory.ini redteam -m ping
   ```

4. **Install git and Go on the instance:**
   ```bash
   ansible-playbook -i inventory.ini playbooks/install-deps.yml
   ```

### Key Configuration Details

- **Region**: `eu-west-3` (Ireland) — configurable via `terraform/terraform.tfvars`
- **Instance Type**: `t3.small` — configurable via `terraform/variables.tf`
- **SSH Key**: Repo-local key at `terraform/keys/id_rsa` (gitignored; create/import as needed)
- **Remote User**: `ubuntu` (configurable per host in Ansible inventory)
- **Ansible Connection**: SSH over port 22 with key-based authentication

For detailed setup instructions, see `terraform/README.md` and `ansible/README.md`.

## Emulation Phases Demonstrated

1. **Initial Access**
   - Hosted a credential-harvesting proxy mimicking Microsoft 365 login
   - Used path-based lures with realistic redirect flows
   - Low to Medium privileged accounts will be used in the demo

2. **Credential & Token Capture**
   - Captured usernames, passwords, MFA responses
   - Successfully harvested session cookies and OAuth tokens (access + refresh)

3. **Post-Exploitation**
   - Validated captured tokens using public tools (e.g., token introspection)
   - Demonstrated potential access to Microsoft Graph API endpoints (/me, /users, mail, files)
   - Explored persistence possibilities (device registration, app consents)

4. **Hybrid Considerations**
   - Discussed how stolen cloud tokens can enable pivots to on-prem resources in hybrid setups
   - Highlighted risks around Entra Connect sync account and password writeback

## Key Learnings

- Traditional MFA (SMS, app push) can be bypassed via real-time session relay
- Primary Refresh Tokens (PRTs) and refresh tokens provide long-term access
- Conditional Access Policies alone are insufficient without phishing-resistant MFA
- Monitoring for unusual sign-ins, token replay, and impossible travel is critical

## Tools & References (Public / Educational)

- MITRE ATT&CK® – Cloud Matrix  
  https://attack.mitre.org/matrices/enterprise/cloud/
- Microsoft Security Blog – AiTM Phishing Posts
- AADInternals (public PowerShell toolkit for Entra ID research)  
  https://github.com/Gerenios/AADInternals
- Atomic Red Team – Cloud Identity Techniques
