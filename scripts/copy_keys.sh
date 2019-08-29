
#!/usr/bin/env bash

source ./key_vars.sh

remote_user=${USER}

read -p "Enter key file name [${key_file}]: " key_file_input
key_file=${key_file_input:-${key_file}}

read -p "Enter key file directory [${key_file_dir}]: " key_file_dir_input
key_file_dir=${key_file_dir_input:-${key_file_dir}}

read -p "Enter remote host [localhost]: " remote_host_input
remote_host=${remote_host_input:-localhost}

read -p "Enter remote user [${remote_user}]: " remote_user_input
remote_user=${remote_user_input:-${remote_user}}

if [ -f ${key_file_dir}/${key_file} ] ; then
  echo "copying key file ${key_file_dir}/${key_file} to ${remote_user}@${remote_host}"
  ssh-copy-id -i ${key_file_dir}/${key_file} ${remote_user}@${remote_host}
else
  echo "key file ${key_file_dir}/${key_file} not found!"
  exit
fi
