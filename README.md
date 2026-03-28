# installscript

Install FriendlyARM `arm-linux-gcc` toolchain with Ansible (or optional shell script).

## Install with Ansible (recommended)

Run locally:

```bash
ansible-playbook ./install-ansible.yml --ask-become-pass
```

Or run online via curl without using `install.sh`:

```bash
curl -fsSL https://raw.githubusercontent.com/chiraitori/installscript/main/install-ansible.yml -o install-ansible.yml
ansible-playbook install-ansible.yml --ask-become-pass
```

## Install with shell script (optional)

```bash
curl -fsSL https://raw.githubusercontent.com/chiraitori/installscript/main/install.sh -o install.sh
less install.sh
bash install.sh
```

## What it does

- Downloads the toolchain archive
- Installs it under `/opt/FriendlyARM/...`
- Adds the toolchain `bin` path to your shell rc file (`~/.bashrc`, `~/.zshrc`, or `~/.profile`)

## After install

```bash
# Source the rc file used by your shell, or open a new terminal session:
# bash: source ~/.bashrc
# zsh:  source ~/.zshrc
# other shells: source ~/.profile
arm-linux-gcc --version
```
