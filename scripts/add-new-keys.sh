#!/usr/bin/env bash
ssh-to-pgp -private-key -i $HOME/.ssh/id_rsa | gpg --import --quiet
ssh-to-pgp -i $HOME/.ssh/id_rsa -o $USER.asc

ssh-to-pgp -private-key -i /etc/ssh/ssh_host_rsa_key | gpg --import --quiet
ssh-to-pgp -i /etc/ssh/ssh_host_rsa_key -o $(hostname).asc
