#!/usr/bin/env bash

# Install requirements
ansible-galaxy install --force --ignore-certs -r requirements.yml -p roles/

ansible-playbook --ask-become-pass -i hosts.yml -vvv test-proxy.yml
