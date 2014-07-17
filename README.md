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
2. **Configure** environnement variable, hostname, ports `binding in atlas.cfg`
2. **Build** the image: `sudo ./launcher build atlas`
5. **Start** the image: `sudo ./launcher start atlas`

Note 1: you can add yourself to the Docker group if you wish to avoid `sudo` with `usermod -aG docker <your-user-name>`.

Note 2: you can build multiple atlas containers with different configurations, changing its name : `sudo ./launcher start atlas-first` and `sudo ./launcher start atlas-test`.

### Configuration

Rename atlas.cfg.sample to atlas.cfg and chaqnge values with your configuration :

- `HTTP_PORT` : http port to access Atlas application
- `SSH_PORT` : port number to ssh to the container
- `HOST` : choose your container hostname
- `MYSQL_PASSWORD` : root mysql pqssword
- `API_KEY` : ID API key for Atlas
- `SITE_KEY` : ID Site key for Atlas
- `SAMPLE_DATA` : set 1 to load a sample dataset
- `SERVER_URL` : atlas URL (for screen capture)
- `SERVER_DATA` : URL to get JSON with markers

### Directory Structure

#### `/cids`

Contains container ids for currently running Docker containers. cids are Docker's "equivalent" of pids. Each container will have a unique git like hash.

#### `/containers`

This directory is for container definitions for your various Discourse containers. You are in charge of this directory, it ships empty.

#### `/image`

Dockerfile for both the base image `atlas_base` and atlas image `Comming soon .....`.

- `atlas_base` contains all the OS dependencies including sshd, apache2, mysql, php5, phantomJS, composer.

- `atlas_20` builds on the base image and configures Atlas Server.


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
    update:     Destroy and build an Atlas App container based on atlas_base (doesn't affects base image)
```

### Upgrading Atlas

Update Atlas Application
  - `git clone https://https://github.com/alexisduque/atlas-docker`
  - `./launcher update atlas`
  - `./launcher start atlas`

Create a new base image by running:

  - `./launcher destroy my_image`
  - `./launcher build my_image`
  - `./launcher start my_image`

[1]: https://github.com/discourse/discourse_docker