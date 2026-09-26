# 1. Essential Base Utilities

Before installing Terraform, ensure your VPS has the necessary tools to download packages, manage code, and parse JSON outputs (which is very common in Terraform automation scripts).

```bash
sudo apt update
sudo apt install -y curl wget git unzip jq software-properties-common

```

- git: Essential for cloning Infrastructure as Code (IaC) repositories.
- jq: A lightweight command-line JSON processor. Terraform outputs are often formatted as JSON, and you will frequently use jq to parse resource IDs into bash variables.
- unzip: Required if you decide to install Terraform binaries manually rather than via a package manager.

# 2. Terraform CLI (Choose One Method)

You have two primary options for installing Terraform. As a developer learning the tool, Option A is highly recommended because it prevents system-wide conflicts when you need to test different versions of Terraform.


## A. tfenv (Recommended for Developers)

tfenv is a version manager for Terraform. It allows you to install and switch between multiple Terraform versions easily, which is crucial as you learn and work on different projects that might be locked to specific versions.


```bash
# Clone tfenv to ~/.tfenv
git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv

# Add to bash profile
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Install the latest stable version (or a specific version like 1.5.7)
tfenv install latest
tfenv use latest

# Verify installation
terraform -v

```

## B. Official HashiCorp APT Repository

If you prefer a standard system-wide installation that updates via apt, use the official repository.

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

```

# 3. Cloud Provider CLIs (Optional but Recommended)

While Terraform communicates with providers using its own API plugins (which it downloads automatically), installing the official Command Line Interface (CLI) for your specific VPS provider is highly recommended. It helps you verify credentials, check resource statuses out-of-band, and debug issues when Terraform fails.

Install the CLI for the provider you are using to manage your VPS:

- DigitalOcean: sudo snap install doctl
- AWS (EC2): sudo apt install awscli
- Hetzner: sudo snap install hcloud
- Vultr: sudo snap install vultr-cli
