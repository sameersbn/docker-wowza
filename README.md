[![Docker Repository on Quay.io](https://quay.io/repository/sameersbn/wowza/status "Docker Repository on Quay.io")](https://quay.io/repository/sameersbn/wowza)

# quay.io/sameersbn/wowza:4.1.2-2

- [Introduction](#introduction)
  - [Contributing](#contributing)
  - [Issues](#issues)
- [Getting started](#getting-started)
  - [Installation](#installation)
  - [Quickstart](#quickstart)
  - [Persistence](#persistence)
  - [Logs](#logs)
- [Maintainance](#maintenance)
  - [Upgrading](#upgrading)
  - [Shell Access](#shell-access)
- [References](#references)

# Introduction

`Dockerfile` to create a [Docker](https://www.docker.com/) container image for [Wowza Streaming Engine](http://www.wowza.com/products/streaming-engine).

This Dockerfile is not provided by or endorsed by Wowza Media Systems.

**NOTE**: By using this image you are agreeing to comply with the [Wowza EULA](https://www.wowza.com/legal)

Wowza Streaming Engine is unified streaming media server software developed by Wowza Media Systems. The server is used for streaming of live and on-demand video, audio, and rich Internet applications over IP networks to desktop, laptop, and tablet computers, mobile devices, IPTV set-top boxes, internet-connected TV sets, game consoles, and other network-connected devices.

## Contributing

If you find this image useful here's how you can help:

- Send a pull request with your awesome features and bug fixes
- Help users resolve their [issues](../../issues?q=is%3Aopen+is%3Aissue).
- Support the development of this image with a [donation](http://www.damagehead.com/donate/)

## Issues

Before reporting your issue please try updating Docker to the latest version and check if it resolves the issue. Refer to the Docker [installation guide](https://docs.docker.com/installation) for instructions.

SELinux users should try disabling SELinux using the command `setenforce 0` to see if it resolves the issue.

If the above recommendations do not help then [report your issue](../../issues/new) along with the following information:

- Output of the `docker version` and `docker info` commands
- The `docker run` command or `docker-compose.yml` used to start the image. Mask out the sensitive bits.
- Please state if you are using [Boot2Docker](http://www.boot2docker.io), [VirtualBox](https://www.virtualbox.org), etc.

# Getting started

## Installation

Automated builds of the image are available on [Quay.io](https://quay.io/repository/sameersbn/wowza) and is the recommended method of installation.

```bash
docker pull quay.io/sameersbn/wowza:4.1.2-2
```

Alternatively you can build the image yourself.

```bash
git clone https://github.com/sameersbn/docker-wowza.git
cd docker-wowza
docker build --tag $USER/wowza .
```

## Quickstart

Before you can start using this image you need to acquire a valid license from Wowza Media Systems for the Wowza Streaming Engine software. If you do not have one, you can [request a free trial license](http://www.wowza.com/pricing/trial) or purchase a license from Wowza Media Systems.

Start Wowza using:

```bash
docker run --name wowza -d --restart=always \
  --publish 1935:1935 --publish 8086:8086 \
  --publish 8087:8087 --publish 8088:8088 \
  --env 'WOWZA_ACCEPT_LICENSE=yes' \
  --env 'WOWZA_KEY=xxxx-xxxx-xxxx-xxxx-xxxx-xxxx-xxxx' \
  --volume /srv/docker/wowza:/var/lib/wowza \
  quay.io/sameersbn/wowza:4.1.2-2
```

**The `--env WOWZA_ACCEPT_LICENSE=yes` parameter in the above command indicates that you agree to the Wowza EULA.**

*Alternatively, you can use the sample [docker-compose.yml](docker-compose.yml) file to start the container using [Docker Compose](https://docs.docker.com/compose/)*

Point your browser to http://localhost:8088 and login using the default username and password:

* username: `admin`
* password: `admin`

Refer to the wowza [quickstart guide](http://www.wowza.com/forums/content.php?3-quick-start-guide) to get started with Wowza.

## Persistence

For Wowza to preserve its state across container shutdown and startup you should mount a volume at `/var/lib/wowza`.

> *The [Quickstart](#quickstart) command already mounts a volume for persistence.*

SELinux users should update the security context of the host mountpoint so that it plays nicely with Docker:

```bash
mkdir -p /srv/docker/wowza
chcon -Rt svirt_sandbox_file_t /srv/docker/wowza
```

At first run the Wowza configuration files, among other things, will be copied into this location. You can manually edit these configurations if required.

## Logs

The Wowza logs are populated in `/var/log/wowza`. You can mount a volume at this location to easily access these logs and/or perform log rotation.

Alternatively you can also use `docker exec` to tail the logs. For example,

```bash
docker exec -it wowza tail -f /var/log/wowza/wowza/wowzastreamingengine_access.log
```

# Maintenance

## Upgrading

To upgrade to newer releases:

  1. Download the updated Docker image:

  ```bash
  docker pull quay.io/sameersbn/wowza:4.1.2-2
  ```

  2. Stop the currently running image:

  ```bash
  docker stop wowza
  ```

  3. Remove the stopped container

  ```bash
  docker rm -v wowza
  ```

  4. Start the updated image

  ```bash
  docker run -name wowza -d \
    [OPTIONS] \
    quay.io/sameersbn/wowza:4.1.2-2
  ```

## Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using Docker version `1.3.0` or higher you can access a running containers shell by starting `bash` using `docker exec`:

```bash
docker exec -it wowza bash
```

# References

  * https://www.wowza.com/legal
  * http://www.wowza.com/products/streaming-engine
