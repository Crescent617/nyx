#!/usr/bin/env bash

# This script is sourced by the main script to set up the environment

# if root then exit 
if [[ $EUID -eq 0 ]]; then
    echo "This script should not be run as root. Please run it as a regular user."
    exit 1
fi

home_dir="$HOME"
git clone 'https://github.com/Crescent617/my-busybox' "$home_dir/my-busybox"

rustup default stable
yadm clone 'https://github.com/Crescent617/dotfiles.git'
