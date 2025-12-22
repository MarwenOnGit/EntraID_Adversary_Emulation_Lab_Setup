#!/bin/bash
# Evilginx2 Local Lab Setup Script
# Educational use only – for isolated adversary emulation labs
# Tested on fresh Ubuntu 22.04 LTS (Desktop or Server)
# Run as root or with sudo

set -e  # Exit on any error

echo "=================================================="
echo "Evilginx2 Local Testing Environment Setup Script"
echo "For educational/red team emulation labs only"
echo "=================================================="
echo

# Update system
echo "[1/6] Updating package lists and upgrading system..."
apt update && apt upgrade -y

# Install dependencies
echo "[2/6] Installing required packages (git, golang, make, openssl)..."
apt install -y git golang-go make openssl

# Clone and build Evilginx2
echo "[3/6] Cloning and building Evilginx2..."
if [ -d "evilginx2" ]; then
  
    echo "evilginx2 directory already exists – pulling latest changes..."
    cd evilginx2
    git pull
else
    git clone https://github.com/kgretzky/evilginx2.git
    cd evilginx2
fi

go mod tidy
go build -o evilginx
sudo cp evilginx /usr/local/bin/evilginx
cd ..

# Add local hosts entries (example for common o365 subdomains)
echo "[6/6] Adding example entries to /etc/hosts (fake domain evil.local)..."
cat << EOF | tee -a /etc/hosts > /dev/null

# Evilginx2 Local Testing Entries (remove when done)
127.0.0.1 evil.local
127.0.0.1 login.evil.local
127.0.0.1 outlook.evil.local
127.0.0.1 www.evil.local
127.0.0.1 login.microsoftonline.evil.local
EOF

echo "Adding evilginx certificate" 
sudo apt update ; sudo cp ~/.evilginx/crt/ca.crt /usr/local/share/ca-certificates/evilginx.crt && sudo update-ca-certificates
echo "Add the certificate manually to the browser before proceeding" 
echo "=================================================="
echo "Setup Complete!"
echo "=================================================="
echo
