#!/usr/bin/env bash

ansible-playbook --ask-become-pass -i hosts.yml -vv test-no-proxy.yml

ansible-playbook --ask-become-pass -i hosts.yml -vv test-proxy.yml
