# installscript

Install FriendlyARM `arm-linux-gcc` toolchain with one command.

## Install (online via curl)

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/chiraitori/installscript/main/install.sh)"
```

## What it does

- Downloads the toolchain archive
- Installs it under `/opt/FriendlyARM/...`
- Adds the toolchain `bin` path to your shell rc file (`~/.bashrc`, `~/.zshrc`, or `~/.profile`)

## After install

```bash
source ~/.bashrc
arm-linux-gcc --version
```
