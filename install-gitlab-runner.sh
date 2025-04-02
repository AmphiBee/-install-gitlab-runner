#!/bin/bash

set -e

# ----------------------
# Get CLI arguments
# ----------------------
GITLAB_URL="$1"
GITLAB_RUNNER_TOKEN="$2"

# ----------------------
# Default configuration
# ----------------------
CONCURRENT_JOBS=4
RUNNER_USER="gitlab-runner"
RUNNER_HOME="/home/$RUNNER_USER"
GITLAB_RUNNER_BINARY_URL="https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64"

# ----------------------
# Validate arguments
# ----------------------
if [ -z "$GITLAB_URL" ] || [ -z "$GITLAB_RUNNER_TOKEN" ]; then
    echo "❌ Missing parameters."
    echo "Usage:"
    echo "curl -s https://raw.githubusercontent.com/your-org/install-gitlab-runner.sh | bash -s <GITLAB_URL> <GITLAB_RUNNER_TOKEN>"
    exit 1
fi

echo "🚀 Installing GitLab Runner for $GITLAB_URL"

# ----------------------
# Download GitLab Runner binary
# ----------------------
curl -L --output /usr/local/bin/gitlab-runner "$GITLAB_RUNNER_BINARY_URL"
chmod +x /usr/local/bin/gitlab-runner

# ----------------------
# Create the gitlab-runner user if it doesn't exist
# ----------------------
if ! id "$RUNNER_USER" &>/dev/null; then
    useradd --comment 'GitLab Runner' --create-home "$RUNNER_USER" --shell /bin/bash
fi

# ----------------------
# Install and start the runner as a service
# ----------------------
gitlab-runner install --user="$RUNNER_USER" --working-directory="$RUNNER_HOME"
gitlab-runner start

# ----------------------
# Register the runner
# ----------------------
gitlab-runner register --non-interactive \
  --url "$GITLAB_URL" \
  --registration-token "$GITLAB_RUNNER_TOKEN" \
  --executor "docker" \
  --docker-image "docker:latest" \
  --description "EC2 GitLab Runner" \
  --tag-list "ec2,aws" \
  --run-untagged="true" \
  --locked="false"

# ----------------------
# Install Docker
# ----------------------
echo "🐳 Installing Docker..."
dnf install -y docker
systemctl enable docker
systemctl start docker

# ----------------------
# Add ec2-user to the docker group
# ----------------------
usermod -aG docker ec2-user

# ----------------------
# Update concurrent jobs configuration
# ----------------------
CONFIG_TOML="/etc/gitlab-runner/config.toml"
if [ -f "$CONFIG_TOML" ]; then
    sed -i "s/^concurrent = .*/concurrent = $CONCURRENT_JOBS/" "$CONFIG_TOML"
    echo "⚙️ Updated concurrent = $CONCURRENT_JOBS in $CONFIG_TOML"
fi

# ----------------------
# Restart GitLab Runner
# ----------------------
systemctl restart gitlab-runner

echo "✅ GitLab Runner installed and configured successfully."