#!/usr/bin/env bash
set -euo pipefail

URL="https://github.com/friendlyarm/prebuilts/raw/refs/heads/master/gcc/arm-linux-gcc-4.5.1-v6-vfp.tar.xz"
ARCHIVE_NAME="${URL##*/}"
TOOLCHAIN_NAME="${ARCHIVE_NAME%.tar.xz}"
INSTALL_BASE="/opt"
EXPECTED_REL_BIN="FriendlyARM/toolschain/4.5.1/bin"
INSTALL_DIR="${INSTALL_BASE}/${EXPECTED_REL_BIN%/bin}"

BLOCK_START="# >>> arm-linux-gcc toolchain >>>"
BLOCK_END="# <<< arm-linux-gcc toolchain <<<"

cleanup() {
  if [[ -n "${TMP_DIR:-}" && -d "${TMP_DIR}" ]]; then
    rm -rf "${TMP_DIR}"
  fi
}

run_as_root() {
  if [[ "${EUID}" -eq 0 ]]; then
    "$@"
    return
  fi

  if command -v sudo >/dev/null 2>&1; then
    sudo "$@"
    return
  fi

  echo "Error: root privilege is required to write to ${INSTALL_BASE}. Install sudo or run this script as root." >&2
  exit 1
}

pick_rc_file() {
  local shell_name
  shell_name="$(basename "${SHELL:-bash}")"

  case "${shell_name}" in
    zsh)
      echo "${HOME}/.zshrc"
      ;;
    bash)
      echo "${HOME}/.bashrc"
      ;;
    *)
      echo "${HOME}/.profile"
      ;;
  esac
}

download_archive() {
  local target_file="$1"

  if command -v curl >/dev/null 2>&1; then
    curl -fL "${URL}" -o "${target_file}"
    return
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -O "${target_file}" "${URL}"
    return
  fi

  echo "Error: need curl or wget to download files." >&2
  exit 1
}

resolve_path_entry() {
  local install_root="$1"
  local gcc_bin
  local bin_dir

  if [[ -d "${install_root}/bin" ]]; then
    echo "${install_root}/bin"
    return
  fi

  gcc_bin="$(find "${install_root}" -type f -name "arm-linux-gcc*" -perm -u+x | head -n 1 || true)"
  if [[ -n "${gcc_bin}" ]]; then
    dirname "${gcc_bin}"
    return
  fi

  bin_dir="$(find "${install_root}" -type d -name bin | head -n 1 || true)"
  if [[ -n "${bin_dir}" ]]; then
    echo "${bin_dir}"
    return
  fi

  echo "Error: could not find toolchain bin directory under ${install_root}" >&2
  exit 1
}

update_shell_rc() {
  local rc_file="$1"
  local path_entry="$2"
  local temp_file

  touch "${rc_file}"

  temp_file="$(mktemp)"
  awk -v start="${BLOCK_START}" -v end="${BLOCK_END}" '
    $0 == start {skip = 1; next}
    $0 == end {skip = 0; next}
    !skip {print}
  ' "${rc_file}" > "${temp_file}"
  mv "${temp_file}" "${rc_file}"

  {
    echo
    echo "${BLOCK_START}"
    echo "export PATH=\"${path_entry}:\$PATH\""
    echo "${BLOCK_END}"
  } >> "${rc_file}"
}

main() {
  local archive_path
  local extract_dir
  local expected_bin
  local extracted_root
  local rc_file
  local path_entry

  echo "Installing required package: lib32z1 (32-bit compatibility library)"
  run_as_root apt-get update
  if ! run_as_root apt-get install -y lib32z1; then
    echo "Error: failed to install required package lib32z1." >&2
    exit 1
  fi
  echo "Installed required package: lib32z1"

  TMP_DIR="$(mktemp -d)"
  trap cleanup EXIT

  archive_path="${TMP_DIR}/${ARCHIVE_NAME}"
  extract_dir="${TMP_DIR}/extract"
  mkdir -p "${extract_dir}"

  echo "Downloading: ${URL}"
  download_archive "${archive_path}"

  echo "Extracting archive..."
  tar -xJf "${archive_path}" -C "${extract_dir}"

  expected_bin="${extract_dir}/opt/${EXPECTED_REL_BIN}"
  if [[ -d "${expected_bin}" ]]; then
    run_as_root rm -rf "${INSTALL_BASE}/FriendlyARM"
    run_as_root mkdir -p "${INSTALL_BASE}"
    run_as_root mv "${extract_dir}/opt/FriendlyARM" "${INSTALL_BASE}/FriendlyARM"
    path_entry="${INSTALL_BASE}/${EXPECTED_REL_BIN}"
  else
    # Fallback for archives that do not contain the FriendlyARM opt-style layout.
    extracted_root="$(find "${extract_dir}" -mindepth 1 -maxdepth 1 | head -n 1 || true)"
    if [[ -z "${extracted_root}" ]]; then
      echo "Error: archive extraction returned empty content." >&2
      exit 1
    fi

    run_as_root rm -rf "${INSTALL_DIR}"
    run_as_root mkdir -p "$(dirname "${INSTALL_DIR}")"
    run_as_root mv "${extracted_root}" "${INSTALL_DIR}"
    path_entry="$(resolve_path_entry "${INSTALL_DIR}")"
  fi

  rc_file="$(pick_rc_file)"

  update_shell_rc "${rc_file}" "${path_entry}"

  echo
  echo "Install completed."
  echo "Toolchain location: ${INSTALL_DIR}"
  echo "PATH entry added to: ${rc_file}"
  echo
  echo "Apply now with: source ${rc_file}"
  echo "Check compiler with: arm-linux-gcc --version"
}

main "$@"
