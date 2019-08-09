# Test Ansible role behaviour behind a proxy

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
Allow  10.57.88.35  # remote node
Allow  10.57.88.21  # remote node
Allow  172.17.0.1/16 # Docker containers
Deny  0/0
```

The proxy can be run in the foreground in order to observe any requests being passed to it using, for example

```
cntlm -f -c ~/cntlm.conf
```


## Instructions

Copy the example Ansible inventory file [`hosts-example.yml`](hosts-example.yml) to `hosts.yml` and set the relevant IP addresses for the `proxy-node` and `remote-node`.

Need to set the following environment proxy variables, as external IP addresses, on each host file `$HOME/.profile`, for example:

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

Copy the example Ansible inventory file [`hosts-example.yml`](hosts-example.yml) to `hosts.yml` and set the relevant IP addresses for the `proxy-node` and `remote-node`.

Run the play using the script [`./run_play.sh`](run_play.sh).

## Test

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
