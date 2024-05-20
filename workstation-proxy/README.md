# Workstation Proxy

This recipe includes the basic infrastructure for a workstation proxy. All services should be Dockerized and run in a single Docker Compose file. Additionally, an nginx service is required to proxy the services to a single domain. This recipe utilities [Nginx Proxy Manager](https://nginxproxymanager.com/) to easily manage the proxy configuration. To allow access outside of the home network, ngrok is used to create a secure tunnel to the workstation and expose the services to the internet. 

## Requirements

- [Docker/Docker Compose](https://docs.docker.com/get-docker/)
- [Ngrok Account](https://ngrok.com/)


## Proxy Setup Instructions

**NOTE**: if you are using git, make sure to add the nginx proxy's `data` and `letsencrypt` volumes to your .gitignore file.

1. Create Dockerfiles for each service that you want to run. Make sure to expose the ports that the service runs on. 
2. Add your services to the `docker-compose.yml` file.
3. Create the `proxynet` network by running `docker network create proxynet`.
4. Run `docker-compose up -d` to start the services.
5. Create an account on ngrok and get your authtoken from the dashboard.
6. Follow the instructions on the ngrok dashboard to install the ngrok client and authenticate it with your authtoken.
7. Create a static domain for your workstation on the ngrok dashboard. This will be the site that you can access your services from.
8. Install the ngrok agent on your workstation by running `sudo apt update && sudo apt install ngrok -y`.
9. Authenticate the ngrok CLI tool by running `ngrok authtoken <your ngrok authtoken>`.
10. Run `ngrok http --domain=<your ngrok static domain> 80` to create a secure tunnel to your workstation. The default port for the Nginx Proxy Manager is 80.
11. Access the Nginx Proxy Manager at `http://localhost:81` and configure the proxy to point to your services. The default credentials are `admin@example.com` and `changeme`.
12. Navigate to "Add Proxy Host" and fill in the following fields:
    - Domain Names: `your ngrok static domain`
    - Forward Hostname/IP: `your service container name`
    - Forward Port: `your service port`
13. Save the configuration and access your services at `https://your ngrok static domain`.


## SSH WSL Setup instructions

1. Install `openssh-server` on the workstation by running `sudo apt update && sudo apt install openssh-server -y`.
2. Configure SSH to allow access on the default port and password authentication by editing the `/etc/ssh/sshd_config` file. Change `#Port 22` to `Port 22` and `#PasswordAuthentication yes` to `PasswordAuthentication yes`.
3. Restart the SSH service by running `sudo service ssh restart`.
4. Test the SSH connection by running `ssh <your wsl username>@localhost -p 22` on the workstation.
5. To get a secure tunnel to the workstation, you will need to use ngrok's TCP tunneling feature. Run `ngrok tcp 22` to create a secure tunnel to the workstation's SSH service. 
6. You should see the following output: 

```
Session Status                online
Account                       <your name> (Plan: <your plan>)
Version                       3.9.0
Region                        United States (us)
Latency                       20 ms
Web Interface                 http://127.0.0.1:4040
Forwarding                    tcp://<ngrok forwarding url>:<ngrok forwarding port> -> localhost:22
```

Test the SSH connection by running `ssh <your wsl username>@<ngrok forwarding url> -p <ngrok forwarding port>`.


## Running Multiple Ngrok Tunnels

Since the free version of ngrok only allows one ngrok agent to run at a time, you will need to modify the ngrok config to start both the proxy service and the ssh tunnel at the same time. Run `ngrok config check` to find the location of the ngrok config file. Add the following lines to the config file:
```yaml
tunnels:
  ssh:
    proto: tcp
    addr: 22
  http:
    proto: http
    addr: 80
```
If already running, stop the ngrok agent and start both the proxy service and the ssh tunnel by running `ngrok start --all`. You should now be able to access both the proxy service and the ssh tunnel at the same time.
