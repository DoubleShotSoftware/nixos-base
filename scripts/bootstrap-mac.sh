#!/usr/bin/env bash
sh <(curl -L https://nixos.org/nix/install) --daemon
source /etc/bashrc
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer