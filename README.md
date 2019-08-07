# Test Ansible play behaviour behind a proxy

## Topolgy

![Topology](docs/ProxyConfiguration.png)

## Instructions

Need to set the following environment proxy variables, as external IP addresses, on each host file `$HOME/.profile`, for example:

```sh
export http_proxy=http://172.16.0.100:3128
export https_proxy=http://172.16.0.100:3128
export no_proxy=http://172.16.0.100:3128
export HTTP_PROXY=http://172.16.0.100:3128
export HTTPS_PROXY=http://172.16.0.100:3128
export NO_PROXY=http://172.16.0.100:3128
```

Set the remote host IP address in the Ansible inventory file [hosts.yml](hosts.yml) and run the play using `./run_play.sh`.

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
