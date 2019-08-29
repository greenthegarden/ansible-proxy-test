#!/usr/bin/env bash

# Install requirements
galaxy_roles_file="requirements.yml"
roles_directory="roles"
if [ ! -f ${galaxy_roles_file} ] ; then
  print "%s%s%s\n" "Requirements file, " ${galaxy_roles_file} ", not found!"
  exit
fi
if [ ! -d ${roles_directory} ] ; then
  print "%s%s\n" "Creating roles directory, " ${roles_directory}
  mkdir ${roles_directory}
fi
ansible-galaxy install --force --ignore-certs -r ${galaxy_roles_file} -p ${roles_directory}/

# run play
inventory_file="hosts.yml"
playbook_file="test-proxy.yml"
if [ ! ${inventory_file} ] ; then
  print "%s%s%s\n" "Ansible inventory file, " ${inventory_file} ", not found!"
  exit
fi
if [ ! ${playbook_file} ] ; then
  print "%s%s%s\n" "Ansible playbook file, " ${playbook_file} ", not found!"
  exit
fi
ansible-playbook --ask-become-pass -i ${inventory_file} -vvv ${playbook_file}
