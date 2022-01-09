#!/usr/bin/env zsh
set -uex

echo $0
zsh --version
htop --version
git --version
chezmoi --version
chezmoi verify
