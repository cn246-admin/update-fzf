#!/bin/sh

# Description: Download and install fzf on Linux and Mac
# Author: Chuck Nemeth
# https://github.com/junegunn/fzf

# VARIABLES
bin_dir="${HOME}/.local/bin"
src_dir="${HOME}/.local/src"
man_dir="${HOME}/.local/man/man1"

fzf_man="fzf.1"
fzf_tmux_man="fzf-tmux.1"

if command -v fzf >/dev/null 2>&1; then
  fzf_installed_version="$(fzf --version | cut -d' ' -f 1)"
else
  fzf_installed_version="Not Installed"
fi

fzf_version="$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest | \
              awk -F': ' '/tag_name/ { gsub(/\"|\,/,"",$2); print $2 }')"

# colored output
code_grn() { tput setaf 2; printf '%s\n' "${1}"; tput sgr0; }
code_red() { tput setaf 1; printf '%s\n' "${1}"; tput sgr0; }
code_yel() { tput setaf 3; printf '%s\n' "${1}"; tput sgr0; }

# OS CHECK
archi=$(uname -sm)
case "$archi" in
  Darwin\ arm64)
    fzf_archive="fzf-${fzf_version##v}-darwin_arm64.tar.gz"
    ;;
  Darwin\ x86_64)
    fzf_archive="fzf-${fzf_version##v}-darwin_amd64.tar.gz"
    ;;
  Linux\ armv5*)
    fzf_archive="fzf-${fzf_version##v}-linux_armv5.tar.gz"
    ;;
  Linux\ armv6*)
    fzf_archive="fzf-${fzf_version##v}-linux_armv6.tar.gz"
    ;;
  Linux\ armv7*)
    fzf_archive="fzf-${fzf_version##v}-linux_armv7.tar.gz"
    ;;
  Linux\ armv[8-9]* | Linux\ aarch64*)
    fzf_archive="fzf-${fzf_version##v}-linux_arm64.tar.gz"
    ;;
  Linux\ *64)
    fzf_archive="fzf-${fzf_version##v}-linux_amd64.tar.gz"
    ;;
  FreeBSD\ *64)
    fzf_archive="fzf-${fzf_version##v}-freebsd_amd64.tar.gz"
    ;;
  OpenBSD\ *64)
    fzf_archive="fzf-${fzf_version##v}-openbsd_amd64.tar.gz"
    ;;
  *)
    code_red "[ERROR] OS not supported!"
    exit 1
    ;;
esac

fzf_url="https://github.com/junegunn/fzf/releases/download/${fzf_version}/${fzf_archive}"

# PATH CHECK
case :$PATH: in
  *:"${bin_dir}":*)  ;;  # do nothing
  *)
    code_red "[ERROR] ${bin_dir} was not found in \$PATH!"
    code_red "Add ${bin_dir} to PATH or select another directory to install to"
    exit 1
    ;;
esac


# VERSION CHECK
if [ "${fzf_version##v}" = "${fzf_installed_version}" ]; then
  printf '%s\n' "Installed Version: ${fzf_installed_version}"
  printf '%s\n' "Latest Version: ${fzf_version}"
  code_yel "[INFO] Already using latest version. Exiting."
  exit 0
else
  printf '%s\n' "Installed Verision: ${fzf_installed_version}"
  printf '%s\n' "Latest Version: ${fzf_version}"
fi


# PREPARE
[ ! -d "${bin_dir}" ] && mkdir -p "${bin_dir}"
[ ! -d "${src_dir}" ] && mkdir -p "${src_dir}"
[ ! -d "${man_dir}" ] && mkdir -p "${man_dir}"


# DOWNLOAD
cd "${src_dir}" || exit

# Clone or update the repository
if [ ! -d "${src_dir}/fzf" ]; then
  printf '%s\n' "Cloning the fzf repository"
  git clone --depth 1 https://github.com/junegunn/fzf.git fzf
else
  printf '%s\n' "Updating the fzf repository"
  cd "${src_dir}/fzf" || exit
  git pull
fi

cd "${src_dir}/fzf/bin" || exit

# Delete old binary
if [ -f "${src_dir}/fzf/bin/fzf" ]; then
  printf '%s\n' "Deleting old fzf binary"
  rm -f "${src_dir}/fzf/bin/fzf"
fi

# Download and extract new binary
printf '%s\n' "Downloading fzf binary"
if command -v curl > /dev/null; then
  curl -fL "${fzf_url}" | tar -xzf -
else
  wget -O - "${fzf_url}" | tar -xzf -
fi

chmod u+x "${src_dir}/fzf/bin/fzf"

# Create symlinks
printf '%s\n' "Creating symlinks"
ln -sf "${src_dir}/fzf/bin/fzf" "${bin_dir}"
ln -sf "${src_dir}/fzf/bin/fzf-tmux" "${bin_dir}"
ln -sf "${src_dir}/fzf/man/man1/${fzf_man}" "${man_dir}"
ln -sf "${src_dir}/fzf/man/man1/${fzf_tmux_man}" "${man_dir}"


# VERSION CHECK
code_grn "Done!"
code_grn "Installed Version: $(fzf --version | cut -d' ' -f 1)"

printf '%s\n' "Make sure to add the following to ~/.vimrc"
printf '%s\n' "Plug '~/.local/src/fzf'"

# vim: ft=sh ts=2 sts=2 sw=2 sr et
