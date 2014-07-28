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
5. **Create a storage** container: `sudo ./launcher storage atlas`
5. **Start Mysql Server** container: `sudo ./launcher start-db atlas`
6. **Start** the image: `sudo ./launcher start atlas`

5. **Backup** your database : `sudo ./launcher backup atlas`, that will create backup_atlas.tar
6. **Restore** your database : `sudo ./launcher restore atlas`, that will restore your database using backup_atlas.tar

**Note 1:** Stop all your running container before restoring data. 

**Note 2:** you can add yourself to the Docker group if you wish to avoid `sudo` with `usermod -aG docker <your-user-name>`.

**Note 3:** you can build multiple atlas containers with different configurations, changing its name : `sudo ./launcher start atlas-first` and `sudo ./launcher start atlas-test`.

### Configuration

Rename atlas.cfg.sample to atlas.cfg and chaqnge values with your configuration :

- `HTTP_PORT` : http port to access Atlas application (use 80, shutdown apache on your host)
- `HTTPS_PORT` : https port to access Atlas application (use 443, shutdown apache on your host)
- `SSH_PORT` : port number to ssh to the container (use, 22 or 23 if sshd is allready running on your host)
- `HOST` : choose your container hostname
- `MYSQL_PASSWORD` : root mysql pqssword
- `API_KEY` : ID API key for Atlas
- `SITE_KEY` : ID Site key for Atlas
- `SAMPLE_DATA` : set 1 to load a sample dataset (you can override existing dump with a new one)
- `SERVER_URL` : your server URL (for ID multipass callback - http://server-ip/)
- `CAPTURE_URL` : your server URL (for ID multipass callback)
- `SERVER_DATA` : URL to get JSON with markers (http://server-ip/data.php?callback=loadSites)

### Directory Structure

#### `/cids`

Contains container ids for currently running Docker containers. cids are Docker's "equivalent" of pids. Each container will have a unique git like hash.

#### `/containers`

This directory is for container definitions for your various Discourse containers. You are in charge of this directory, it ships empty.

#### `/image`

Dockerfile for both the base image `atlas_base` and atlas image `Comming soon .....`.

- `atlas_base` contains all the OS dependencies including sshd, apache2, mysql, php5, phantomJS, composer.

- `atlas_20` builds on the base image and configures Atlas Server.

- `atlas_database` builds a simple Mysql Server container.

- `atlas_volume` create a volume container, required by datatbase container to persist data.

### Launcher

The base directory contains a single bash script which is used to manage containers. You can use it to "build" a new container, ssh in, start, stop and destroy a container.

```
Usage: launcher COMMAND CONFIG

  start:      Start/initialize an atlas container
  start-db:   Start/initialize a mysql container
  storage:    Start/initialize an empty storage container
  restore:    Restore data from ./backup.tar to storage container
  backup:     Create a backup of storage container to ./backup.tar
  stop:       Stop an atlas and mysql running container
  restart:    Restart a container
  destroy:    Stop and remove a container
  ssh:        Start a bash shell in a running container
  logs:       Docker logs for container
  build:      Destroy and build an Atlas App container based on atlas_base (doesn't affects base image)
  update:     Destroy and build an Atlas App container based on atlas_base
  rebuild:    Rebuild a container (destroy old, bootstrap, start new)
  clean:      Stop all containers and  remove all images from your local history !DANGER!
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
