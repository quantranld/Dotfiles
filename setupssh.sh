#!/bin/bash
#
# Script to automate SSH server setup on Ubuntu with GitHub SSH key
#
#set -x # Uncomment for debugging

# Update package lists
apt update -y

# Install OpenSSH server
apt install openssh-server -y

# Check if sshd service exists and restart
if systemctl status sshd.service > /dev/null 2>&1; then
  echo "sshd.service found, restarting..."
  systemctl restart sshd.service
else
  echo "sshd.service not found, trying ssh.service..."
  if systemctl status ssh.service > /dev/null 2>&1; then
    echo "ssh.service found, restarting..."
    systemctl restart ssh.service
  else
    echo "Neither sshd.service nor ssh.service found.  Attempting to start ssh..."
    systemctl start ssh
    if [ $? -eq 0 ]; then
      echo "ssh started successfully."
    else
      echo "Failed to start ssh service.  Please investigate manually."
      exit 1
    fi
  fi
fi

# Configure SSH server security settings
sed -i 's/^#Port 22/Port 2222/' /etc/ssh/sshd_config # Change to port 2222 or another non-standard port
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i '/^Ciphers/s/#//' /etc/ssh/sshd_config #Enforce secure ciphers
sed -i '/^MACs/s/#//' /etc/ssh/sshd_config #Enforce secure MACs
echo "
# Enforce stronger Ciphers and MACs
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-ctr,aes128-gcm@openssh.com,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
" >> /etc/ssh/sshd_config

# Generate SSH key for the user
echo "Generating SSH key for the default user..."
ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/id_rsa -C "qmenq07@gmail.com" # No passphrase for automation, include email

# Get the public key
PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub)

# Output the public key and instructions
echo "
--------------------------------------------------------------------------------
SSH key generated!

To add it to your GitHub account:

1.  Go to your GitHub account settings: https://github.com/settings/ssh
2.  Click on 'New SSH key' or 'Add SSH key'.
3.  Give it a title (e.g., 'Ubuntu Server').
4.  Paste the following public key:
"
echo "$PUBLIC_KEY"
echo "
5.  Click 'Add SSH key'.
--------------------------------------------------------------------------------
"

echo "SSH server has been configured.  Remember to use port 2222 (or the port you set) when connecting."
echo "Key-based authentication is now required.  Ensure you have added the public key to your GitHub account."

# Pause and wait for user confirmation
echo "
--------------------------------------------------------------------------------
Have you added the SSH key to your GitHub account? (y/n)
--------------------------------------------------------------------------------
"
read -r USER_RESPONSE

if [ "$USER_RESPONSE" = "y" ]; then
  # Ensure the SSH agent is running
  eval "$(ssh-agent -s)"

  # Add the private key to the agent
  ssh-add ~/.ssh/id_rsa

  # Test the SSH connection to GitHub
  echo "Testing SSH connection to GitHub..."
  ssh -T git@github.com
  if [ $? -eq 0 ]; then
    echo "Successfully connected to GitHub!"
  else
    echo "Failed to connect to GitHub.  Please check your SSH key setup."
    echo "Possible issues:
    - Key not added to GitHub account.
    - Incorrect permissions on ~/.ssh/id_rsa."
  fi
else
  echo "Please add the SSH key to your GitHub account and re-run this script to test the connection."
  exit 1
fi