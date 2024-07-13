# Automated Server Environment Setup Script

This script automates the setup of my server environment, tailored specifically for my needs.

## Features

- Updates package lists (`apt update`).
- Changes the root password to a specified one.
- Installs essential packages required for my server setup.
- Sets up SSH key authentication for secure remote access.
- Installs Tailscale for secure networking.
- Prints out the status of each setup step for easy monitoring and verification.

## Usage

1. Ensure you have a Debian-based Linux server (like Ubuntu) with root access.
2. Download the script to your server using `wget`:
   ```bash
   wget https://raw.githubusercontent.com/jobintosh/firststep/main/setup.sh
   ```
3. Make the script executable with `chmod +x setup.sh`.
4. Run the script as root: `sudo ./setup.sh`.
5. Follow the prompts and monitor the script's progress as it sets up your server environment.

### Notes

- After completing the setup, remember to change default passwords for security reasons.

### Example Output

Upon completion, the script will display

- SSH service status and enablement.
- FTPS service status and enablement.
- Docker service status and enablement.
- Docker Compose version.
- Public and private IP addresses.
- Current user and available disk space.

---
