# Test Ansible roles behind a proxy and firewall

## Introduction

This project was created to understand how to configure hosts which may be behind a proxy and have a firewall set to run Ansible unmodified roles. Not needing to modify the roles enables [Ansible Galazy](https://galaxy.ansible.com/) roles to be utilised directly, reducing the maintence overhead of maintaining a large number of base roles. A second objective of the project is to test the utilisation of a single proxy instance in order to reduce the risks associated with running multiple password protected proxies. The type of topololgy which is therefore utilised is shown in the following figure.

![Topology](docs/ProxyConfiguration.png)

In order to allow Ansible roles to be utilised behind a proxy Ansible requires the following environment variables to be defined:

| variable    | used by         |
| ----------- | --------------- |
| http_proxy  | pkg_mgr, docker |
| https_proxy | pkg_mgr, docker |
| no_proxy    | pkg_mgr, docker |
| HTTP_PROXY  | pip             |
| HTTPS_PROXY | pip             |
| NO_PROXY    | pip             |

Ansible uses the following different apporaches to get environment varialbes from the controller and remote nodes.

The Ansible [env lookup](https://docs.ansible.com/ansible/latest/plugins/lookup/env.html) plugin allows the query of environment variables on the controller, for example

```
http_proxy: "{{ lookup('env', 'http_proxy') | default(omit) }}"
```

To return the equivalent variable on a remote node, use

```
http_proxy: "{{ ansible_env.http_proxy | default(omit) }}"
```

The following roles are included in the playbook, [`test-proxy.yml`](test-proxy.yml) to test whether the configuration works:

* use wget to download the file defined by variable `file_remote`.
* install a package defined by variable `install_package`.
* use the Galazy Ansible role [geerlingguy.pip](https://github.com/geerlingguy/ansible-role-pip.git) to install pip and a module defined, in the following format, by the variable `pip_install_packages`

```
[ { 'name': 'docker', 'state': 'latest' } ]
```

* use the Galazy Ansible role [geerlingguy.docker](https://github.com/geerlingguy/ansible-role-docker.git) to install Docker.
* pull and run the docker image `portainer/portainer:1.22.0` from [Docker Hub](https://hub.docker.com/).

## Proxy Configuration

[Cntlm](http://cntlm.sourceforge.net/) is assumed to be utilised as a proxy and therefore needs to be installed on the host designated as the `proxy-node`. The following changes are required to be made to the cntlm configuration file, in addition to the corporate settings required for the proxy to work. To easily manage the proxy it is suggested to use a configuration file in user space rather than the global one in `/etc/cntlm.conf`.

Set the port cntlm will listen to 3128, for all interefaces, by ensuring the only `Listen` statement is 

```
Listen 3128
```

Enable the gateway by setting

```
Gateway yes
```

Restrict access to the proxy by specifying the addresses of all remote nodes, along with localhost, and any docker networks, for example

```
Allow  127.0.0.1    # localhost
Allow  172.16.0.100  # proxy node
Allow  172.16.0.101  # remote node
Allow  172.17.0.1/16 # Docker containers
Deny  0/0
```

The proxy can be run in the foreground in order to observe any requests being passed to it using, for example

```
cntlm -f -c ~/cntlm.conf
```

## Running

The following environment proxy variables need to be set, as external IP addresses, on the node from which Ansible is run, in the file `$HOME/.profile`, for example:

If running bash shell

```bash
proxy_ip=172.16.0.100
proxy_port=3128
no_proxy_list=localhost,127.0.0.1
export http_proxy=http://$proxy_ip:$proxy_port
export https_proxy=http://$proxy_ip:$proxy_port
export no_proxy=$no_proxy_list
export HTTP_PROXY=http://$proxy_ip:$proxy_port
export HTTPS_PROXY=http://$proxy_ip:$proxy_port
export NO_PROXY=$no_proxy_list
```

If running tcsh or csh

```tcsh
set proxy_ip=172.16.0.100
set proxy_port=3128
set no_proxy_list=localhost,127.0.0.1
setenv http_proxy http://$proxy_ip:$proxy_port
setenv https_proxy http://$proxy_ip:$proxy_port
setenv no_proxy $no_proxy_list
setenv HTTP_PROXY http://$proxy_ip:$proxy_port
setenv HTTPS_PROXY http://$proxy_ip:$proxy_port
setenv NO_PROXY $no_proxy_list
```

To run the play on existing infrastructure, copy the example Ansible inventory file [`hosts-example.yml`](hosts-example.yml) to `hosts.yml` and set the relevant IP addresses for the `proxy-node` and `remote-node` nodes. Run the play from the host in which the proxy environment variables wre set in the file `$HOME/.profile` using the script [`./run_play.sh`](run_play.sh).

In addition, a [Vagrant](https://www.vagrantup.com/) script is included which will utilise [VirtualBox](https://www.virtualbox.org/) to automatically provision nodes with the topology shown in the figure above in order to test the roles in the case without a proxy or firewall. Run the Vagrant script using `vagrant up`.

## Docker Container Test

To test within a Docker container, use an Alpine container on the remote host, for example

```sh
docker pull alpine:latest
docker run -it alpine:latest
```

Within the container, test external access using

```sh
wget http://www.google.com
```

## Sources:

* https://docs.ansible.com/ansible/latest/user_guide/playbooks_environment.html
* https://docs.docker.com/network/proxy/
* https://medium.com/@saniaky/configure-docker-to-use-a-host-proxy-e88bd988c0aa
