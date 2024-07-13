#!/bin/bash

# Function to switch to root user
switch_to_root() {
  echo "Switching to root user..."
  sudo su - <<EOF
  $(cat $0)
EOF
  exit 0
}

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  switch_to_root
fi

# Update and upgrade packages
apt-get update
apt-get upgrade -y

# Enable root user and set password
echo "root:jobintoshsetup123@#" | chpasswd

# Install necessary packages
apt-get install -y pv wget net-tools openssh-server curl vsftpd docker.io docker-compose

# Enable and start SSH service
systemctl enable ssh
systemctl start ssh

# Make pv executable
chmod +x /usr/bin/pv

# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Configure sysctl settings for Tailscale
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

# Add SSH key
mkdir -p ~/.ssh
wget -O ~/.ssh/authorized_keys https://raw.githubusercontent.com/jobintosh/firststep/main/ssh-auth/id_rsa.pub
chmod 600 ~/.ssh/authorized_keys

# Edit SSH config to disable password authentication
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Restart SSH service to apply changes
systemctl restart ssh

# Configure vsftpd for FTPS
cat <<EOL > /etc/vsftpd.conf
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=YES
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
require_ssl_reuse=NO
ssl_ciphers=HIGH
pasv_min_port=10000
pasv_max_port=10100
EOL

# Restart vsftpd service to apply changes
systemctl restart vsftpd

# Enable vsftpd service to start on boot
systemctl enable vsftpd

# Check SSH, vsftpd, Docker, and Docker Compose service status
ssh_status=$(systemctl is-active ssh)
ssh_enabled=$(systemctl is-enabled ssh)
vsftpd_status=$(systemctl is-active vsftpd)
vsftpd_enabled=$(systemctl is-enabled vsftpd)
docker_status=$(systemctl is-active docker)
docker_enabled=$(systemctl is-enabled docker)
docker_compose_version=$(docker-compose --version)

# Get public IP, private IP, current user, and disk space
public_ip=$(curl -s ifconfig.me)
private_ip=$(hostname -I | awk '{print $1}')
current_user=$(whoami)
disk_space=$(df -h / | grep / | awk '{print $4}')

# Print completion message and system information
echo "Setup complete"
echo "SSH Service Status: $ssh_status"
echo "SSH Service Enabled: $ssh_enabled"
echo "FTPS Service Status: $vsftpd_status"
echo "FTPS Service Enabled: $vsftpd_enabled"
echo "Docker Service Status: $docker_status"
echo "Docker Service Enabled: $docker_enabled"
echo "Docker Compose Version: $docker_compose_version"
echo "Public IP: $public_ip"
echo "Private IP: $private_ip"
echo "Current User: $current_user"
echo "Disk Space Left: $disk_space"

# Reminder to change default passwords
echo ""
echo "Don't forget to change default passwords for users and root after completing setup!"
