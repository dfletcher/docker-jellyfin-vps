# Jellyfin over a VPS with Docker

This `docker-compose` solution lauches Jellyfin along with a tunnel connection to a remote server that can be reached from the internet. It exposes your media collection so you can access it remotely anywhere a browser or Jellyfin client is available.

This SSH reverse proxy solution means your Jellyfin instance can be accessed from the internet without requiring any special configuration of home routers to achieve it. By using `docker-compose`, Jellyfin and the tunnel to the server are launched together and shut down together. The system is configured to survive a restart of the Docker host.

On your VPS server, SSH access and the ability to modify `/etc/ssh/sshd_config` is required. On your media center server, Docker and git are required (and nothing else).

## Setup instructions

*Note* if you want to run the server on port 80 instead of the default 8096 see additional instructions below before proceeding.

1. On your media server, install `docker` and `docker-compose` via package manager, official Docker installer, or by building from source code.

1. `git clone dfletcher/docker-jellyfin-vps`

1. `cd docker-jellyfin-vps`

1. `cp env-SAMPLE .env` and modify the .env file with your host name or IP address and user name.

1. Edit `docker-compose.yml`. This file defines your media shares. Modify the `volumes` section to specify where your TV, music and movies live.

1. `docker-compose up -d`

1. Bringing up the server will create a public and private key into the ./keys directory. `cat keys/id_rsa.pub` and copy the entire public key to your clipboard.

1. SSH to your server.

1. On your server, edit the file `/etc/ssh/sshd_config`. Uncomment the line with `GatewayPorts` and change "no" to "yes". This is necessary so that the tunnel can receive traffic from outside the server host. 

1. Also on your server, change to the home directory of the user that will "own" the tunnel. Could be a user created by your hosting facility like `ubuntu` or you can add a system user for this purpose. Edit the file `/home/$USER/.ssh/authorized_keys`. Paste your public key from step 7 into this file on it's own line. Save the file and exit editor.

1. `service sshd restart` or equivalent for your local Linux.

1. `exit` the server.

After configuration, you should be able to connect to http://\<server-ip-addr-or-dns\>:8096 and configure Jellyfin.

If anything has gone wrong, try `docker-compose logs ssh` and/or `docker-compose logs jellyfin` and check if anything looks wrong.

## Alternative setup on port 80

The above instructions change a little if you want to run on port 80. It requires the login user to be root.

On your server in `/etc/ssh/sshd_config` you will need to uncomment or add this line:

    PermitRootLogin prohibit-password

Don't forget to restart sshd.

In the .env settings file set `REMOTE_USER=root` and `TUNNEL_REMOTE_PORT=80`. Obviously these should be set before running `docker-compose up`.
