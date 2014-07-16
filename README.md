Atlas Docker Application
============
A Docker image for OpenMRS Atlas http://atlas.openmrs.org

*Inspired by [Discourse Docker][1]*

### IMPORTANT: Before You Start

1. Make sure you're running a **64 bit** version of either [Ubuntu 12.04 LTS](http://releases.ubuntu.com/precise/),  or [Ubuntu 14.04](http://releases.ubuntu.com/14.04/).
1. Upgrade to the [latest version of Docker](http://docs.docker.io/en/latest/installation/ubuntulinux/).
1. Run the docker installation and launcher as **root** or a member of the **docker** group.
1. Add your user account to the docker group: `usermod -a -G docker yourusername` and re-login.

If you do not do any of the above, as RoboCop once said, ["there will be… trouble."](http://www.youtube.com/watch?v=XxarhampSNI) *Please double check the above list before proceeding!*

### Getting Started

The simplest way to get started is the  **standalone** template:

1. **Clone** this project from github into `/var/atlas` on your server: `git clone https://github.com/alexisduque/atlas-docker.git /var/atlas`
2. **Build** the image: `sudo ./launcher build atlas`
5. **Start** the image: `sudo ./launcher start atlas`

Note: you can add yourself to the Docker group if you wish to avoid `sudo` with `usermod -aG docker <your-user-name>`.

### Directory Structure

#### `/cids`

Contains container ids for currently running Docker containers. cids are Docker's "equivalent" of pids. Each container will have a unique git like hash.

#### `/containers`

This directory is for container definitions for your various Discourse containers. You are in charge of this directory, it ships empty.

#### `/image`

Dockerfile for both the base image `atlas_base` and atlas image `Comming soon .....`.

- `atlas_base` contains all the OS dependencies including sshd, apache2, mysql, php5, phantomJS, composer.

- `Todo ....` builds on the base image and configures Atlas Server.


### Launcher

The base directory contains a single bash script which is used to manage containers. You can use it to "build" a new container, ssh in, start, stop and destroy a container.

```
Usage: launcher COMMAND CONFIG
Commands:
    start:      Start/initialize a container
    stop:       Stop a running container
    restart:    Restart a container
    destroy:    Stop and remove a container
    ssh:        Start a bash shell in a running container
    logs:       Docker logs for container
    build:      Build a container for the config based on a template
```

### Upgrading Atlas - TODO

The Docker setup gives you multiple upgrade options:

Create a new base image by running:

  - `./launcher destroy my_image`
  - `./launcher build my_image`
  - `./launcher start my_image`

[1]: https://github.com/discourse/discourse_docker