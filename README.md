# 🛠️ GitLab Runner EC2 Installer

This script automates the setup of a **GitLab Runner with Docker executor** on an **Amazon Linux EC2 instance**.  
It installs Docker, configures the runner, and registers it with your GitLab instance in one command.

## 🚀 Usage

Run the following command directly on your EC2 instance:

```bash
curl -s https://raw.githubusercontent.com/AmphiBee/-install-gitlab-runner/main/install-gitlab-runner.sh | bash -s <GITLAB_URL> <REGISTRATION_TOKEN>
```

Replace:

- `<GITLAB_URL>` with your GitLab instance URL (e.g., `https://git.amphibee.fr`)
- `<REGISTRATION_TOKEN>` with the runner registration token (found in GitLab under **Admin Area > CI/CD > Runners**)

### Example

```bash
curl -s https://raw.githubusercontent.com/AmphiBee/-install-gitlab-runner/main/install-gitlab-runner.sh | bash -s https://git.amphibee.fr glrt-xxxxxxxxxxxxxx
```

## ✅ Features

- Installs the latest GitLab Runner binary
- Creates the `gitlab-runner` system user
- Installs Docker via `dnf`
- Registers the runner with Docker executor
- Configures up to 4 concurrent jobs
- Adds `ec2-user` to the `docker` group

## 📁 Files

- [`install-gitlab-runner.sh`](./install-gitlab-runner.sh): the main script to automate setup

## 🧾 Requirements

- Amazon Linux 2 (or compatible)
- Admin (sudo) privileges

## 📌 Notes

- Docker is installed via `dnf`, make sure your EC2 AMI is compatible.
- The script is **idempotent** and can be safely run multiple times.

## 📄 License

MIT License