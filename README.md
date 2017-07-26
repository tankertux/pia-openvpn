
# Private Internet Access OpenVPN Client 
Private Internet Access docker container

forked from: https://github.com/ColinHebert/pia-openvpn

Based on Apline Linux to be tiny!

Enhancements added by swmacdonald (aka mrcaution):
 - pull the PIA client config at build time from PIA website
 - added apk update to get latest patches incorporated into container os
 - clean up temp and apk cache to save space
 - resolved an issue with the ability to use a file for the username and password
 - updated openvpn commandline options to include --auth-nocache to prevent passwords from being cached in memory

kudos to Colin for the excellent work! 

# What is Private Internet Access
Private Internet Access VPN Service encrypts your connection and provides you with an anonymous IP to protect your privacy.

# How to use this image
This image provides the configuration file for each region managed by PIA.

The goal is to start this container first then run other container within the PIA VPN via `--net=container:pia`.


## Starting the client
```Shell
docker run --privileged --cap-add=NET_ADMIN --device=/dev/net/tun --name=pia -d \
  --dns 209.222.18.222 --dns 209.222.18.218 \
  -e 'REGION=US East' \
  -e 'USERNAME=pia_username' \
  -e 'PASSWORD=pia_password' \
  mrcaution/pia-openvpn
```

Due to the nature of the VPN client, this container must be started with some additional privileges, `--privileged`, `--cap-add=NET_ADMIN` and `--device=/dev/net/tun` make sure that the tunnel can be created from within the container.

Starting the container in privileged mode seems to be required. I was unable to get this to work with the /dev/net/tun without running in privileged mode.

## Creating a container that uses PIA VPN
```Shell
docker run --rm --net=container:pia \
    tutum/curl \
    curl -s ifconfig.co
```

The IP address returned after this execution should be different from the IP address you would get without specifying `--net=container:pia`.

# Advanced usage

## Additional arguments for the openvpn client
Every parameter provided to the `docker run` command is directly passed as an argument to the [openvpn executable](https://openvpn.net/man.html).

This will run the openvpn client with the `--pull` option:
```Shell
docker run ... --name=pia \
  mrcaution/pia-openvpn \
    --pull
```

## Avoiding using environment variables for credentials
By default this image relies on the variables `USERNAME` and `PASSWORD` to be set in order to successfully connect to the PIA VPN.

It is possible to use instead a pre-existing volume/file containing the credentials. (Note the :Z for SELINUX) 
```Shell
docker run ... --name=pia \
  -e 'REGION=US East' \
  -v '/hostpath/auth.conf:/etc/openvpn/auth.conf:Z' \
  mrcaution/pia-openvpn \
    --auth-user-pass auth.conf
```

## Connection between containers behind PIA
Any container started with `--net=container:...` will use the same network stack as the underlying container, therefore they will share the same local IP address.

[Prior to Docker 1.9](https://docs.docker.com/engine/userguide/networking/default_network/dockerlinks/) `--link=pia:mycontainer` was the recommended way to connect to a specific container.

[Since Docker 1.9](https://docs.docker.com/engine/userguide/networking/dockernetworks/), it is recommended to use a non default network allowing containers to address each other by name.

### Creation of a network
```Shell
docker network create pia_network
```

This creates a network called `pia_network` in which containers can address each other by name; the `/etc/hosts` is updated automatically for each container added to the network.

### Start the PIA container in the pia_network
```Shell
docker run ... --net=pia_network --name=pia mrcaution/pia-openvpn
```

In `pia_network` there is now a resolvable name `pia` that points to that newly created container.

### Create a container behind the PIA VPN
This step is the same as the earlier one
```Shell
# Create an HTTP service that listens on port 80
docker run ... --net=container:pia --name=myservice myservice
```

This container is not addressable by name in `pia_network`, but given that the network stack used by `myservice` is the same as the `pia` container, they have the same IP address and the service running in this container will be accessible at `http://pia:80`.

### Create a container that access the service
```Shell
docker run ... --net=pia_network tutum/curl curl -s http://pia/
```

The container is started within the same network as `pia` but is not behind the VPN.
It can access services started behind the VPN container such as the HTTP service provided by `myservice`.

### Access the service from your local network
A service created behind the VPN container will not be accessible from a client located outside of the server on which it runs. This is because Docker runs on a different IP range than such client, and therefore the client's traffic is considered as non-local and is routed out through the VPN.

The environment variable LOCAL_NETWORK can be set to let the `pia` container know the range corresponding to your local network. For instance, if your local network uses IP range `192.168.1.0/24` and the service listens on port 80 (provided that the server's firewall is set to not block port 80):
```Shell
docker run ... -p 80:80 -e LOCAL_NETWORK=192.168.1.0/24 --net=pia_network --name=pia mrcaution/pia-openvpn
docker run ... --net=container:pia --name=myservice myservice
```

This is inspired by [haugene/docker-transmission-openvpn](https://github.com/haugene/docker-transmission-openvpn).
