#!/bin/bash

set -e

SERVER="$1"
USER="root"

if [ -z "$SERVER" ] || [ -z "$USER" ]; then
  echo "Usage: ./bootstrap.sh <server_ip>"
  exit 1
fi

echo "[1] Checking SSH key..."

if [ ! -f ~/.ssh/id_rsa.pub ]; then
  echo "No SSH key found. Generating..."
  ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
else
  echo "SSH key exists."
fi

echo "[2] Copying SSH key to server..."
ssh-copy-id ${USER}@${SERVER}

echo "[3] Installing dependencies..."
sudo apt update
sudo apt install -y ansible git wget

echo "[4] Cloning deploy repo..."
cd ~

if [ ! -d "ansible-stack" ]; then
  git clone https://github.com/trumpeta/ansible-stack.git
fi

cd ansible-stack

echo "[5] Running Ansible playbook..."
ansible-playbook -i "${SERVER}," -u ${USER} interactive_full.yml

echo "DONE"
