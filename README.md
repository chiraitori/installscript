# installscript

Install FriendlyARM `arm-linux-gcc` toolchain with one command.

## Install (online via curl)

Recommended: download first, review, then run.

```bash
curl -fsSL https://raw.githubusercontent.com/chiraitori/installscript/main/install.sh -o install.sh
less install.sh
bash install.sh
```

Optional one-line install:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chiraitori/installscript/main/install.sh)"
```

## What it does

- Downloads the toolchain archive
- Installs it under `/opt/FriendlyARM/...`
- Adds the toolchain `bin` path to your shell rc file (`~/.bashrc`, `~/.zshrc`, or `~/.profile`)

## After install

```bash
# Source the rc file used by your shell, or open a new terminal session.
# Example for bash:
source ~/.bashrc
arm-linux-gcc --version
```
