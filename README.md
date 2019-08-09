# Test Ansible play behaviour behind a proxy

## Topolgy

![Topology](docs/ProxyConfiguration.png)

## Instructions

The play is designed to be able to run on tolopologies where there is or is not a proxy running. 
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
