Atlas Docker Application
============
A Docker image for OpenMRS Atlas http://atlas.openmrs.org

**Hosted on Docker Hub**.

**To Run It :**
`docker run -e HOST_IP=127.0.0.1 -p 80:80 -p 443:443 -p 8888:8888 -p 22:22 --name atlas -h atlas openmrs/atlas:2.0` :smile:
*and replace 127.0.0.1 with your host ip or domain name*
### IMPORTANT: Before You Start

1. Make sure you're running a **64 bit** version of either [Ubuntu 12.04 LTS](http://releases.ubuntu.com/precise/),  or [Ubuntu 14.04](http://releases.ubuntu.com/14.04/).
1. Upgrade to the [latest version of Docker](http://docs.docker.io/en/latest/installation/ubuntulinux/).
1. Run the docker installation and launcher as **root** or a member of the **docker** group.
1. Add your user account to the docker group: `usermod -a -G docker yourusername` and re-login.
1. Make sure Apache is not runnig if you want to use 80 and 443 ports.

### Pull the container and run it

1. **Pull** this container from Docker Hub : ``docker pull openmrs/atlas:2.0``
2. **Run** with environnement variable, hostname, ports 
`docker run -e HOST_IP=127.0.0.1 -p 80:80 -p 443:443 -p 8888:8888 -p 22:22 --name atlas -h atlas openmrs/atlas:2.0`
3. **Shutdow** the container when you finish your work : ``docker stop atlas``
4. **Start** the container when needed : ``docker start atlas``

### Configuration

You can run the container specifying these environement variables : 

- `HOST_IP` : your host IP or domain main **required** (defaut value is localhost)

**If you want ton change Atlas container port bing** (change -p HOST_PORT:CONTAINER_PORT in the container command too)

- `HTTP_PORT` : http port to access Atlas application (default : 80)
- `HTTPs_PORT` : https port to access Atlas application default : 443)
- `SSH_PORT` : port number to ssh to the container (default : 22)
- `MYSQL_PASSWORD` : root mysql pqssword (default : mysql)
- `SAMPLE_DATA` : set 1 to load a sample dataset (default : 1)

**Deprecated** If you have a *special* configuration

- `SERVER_URL` : your server URL (for ID multipass callback - https://server-ip/)
- `CAPTURE_URL` : your server URL (default : https://atlas.openmrs.org))
- `SERVER_DATA` : URL to get JSON with markers (http://server-ip/data.php?callback=loadSites)

