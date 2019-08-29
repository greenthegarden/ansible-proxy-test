#!/usr/bin/env bash

# see https://www.ssh.com/ssh/keygen for details

source ./key_vars.sh

if [ -f ${key_file_dir}/${key_file} ] ; then
  echo "key file ${key_file_dir}/${key_file} already exists"
  exit
else
  echo "generating key file ${key_file_dir}/${key_file} using ${key_algorithm} algorithm with size ${key_size}"
  ssh-keygen -t ${key_algorithm} -b ${key_size} -C ${key_comment} -f ${key_file_dir}/${key_file}
fi
