#!/usr/bin/env bash

export key_algorithm="rsa" # one of rsa, dsa, ecdsa, ed25519
export key_size="4096"
export key_comment="vagrant-azure"
export key_file="id_${key_algorithm}_vagrant-azure"
export key_file_dir="${HOME}/.ssh"
