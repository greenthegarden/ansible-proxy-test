#!/usr/bin/env bash

ansible-playbook -i hosts.yml -vv test-no-proxy.yml

ansible-playbook -i hosts.yml -vv test-proxy.yml
