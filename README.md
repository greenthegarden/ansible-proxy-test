# Test Ansible play behaviour behind a proxy

## Sources:

https://medium.com/@saniaky/configure-docker-to-use-a-host-proxy-e88bd988c0aa

## Instructions

Need to set the following environment variables on the host, as external IP addresses:

http_proxy
https_proxy
no_proxy

To test with docker

```bash
docker pull alpine:latest
docker run -it alpine:latest
```

To enable external access from within a container, need to configure proxy to allow connections from Docker IP range (i.e. 172.17.0.0/24)
Within container, test external access using

```bash
wget http://www.google.com
```
