Atlas Docker Application
============
A Docker image to easily hack and contribute to OpenMRS Atlas http://atlas.openmrs.org

**Hosted on Docker Hub**.

**Run It First Time:**
```sh
# Fork atlas repo and clone it
git clone https://github.com/your-git-account/openmrs-contrib-atlas.git  /home/user/atlas-source

# Stop apache if its running (80, 443, 8888 port required)
sudo service apache2 stop

# Build the container
docker run -e HOST_IP=127.0.0.1 -v /home/user/atlas-source:/opt/atlas -p 80:80 -p 443:443 -p 8888:8888 -p 22:22 --name atlas -h atlas openmrs/atlas:2.0-dev
```
- **change** 127.0.0.1 to your **host ip** or domain name
- **change** /home/user/atlas-source to your **local atlas source** folder

### IMPORTANT: Before You Start

1. Make sure you're running a **64 bit** version of either [Ubuntu 12.04 LTS](http://releases.ubuntu.com/precise/),  or [Ubuntu 14.04](http://releases.ubuntu.com/14.04/).
1. Upgrade to the [latest version of Docker](http://docs.docker.io/en/latest/installation/ubuntulinux/).
1. Run the docker installation and launcher as **root** or a member of the **docker** group.
1. Add your user account to the docker group: `usermod -a -G docker yourusername` and re-login.
1. Make sure Apache is not runnig if you want to use 80 and 443 ports.

### Working with the container

1. **Shutdow** the container when you finish your work : ``docker stop atlas``
2. **Start** the container when needed : ``docker start atlas``
3. **Delete** the container : ``docker rm atlas``

### Tips

- You can ssh the container (credentials: root/password) : `ssh root@0.0.0.0 `
- OpenMRS credential for Atlas Sign In : user/user
- Mysql server admin credentials : root/mysql 

### Configuration

You can run the container specifying these environement variables : 

- `HOST_IP` : your host IP or domain main **required** (defaut value is localhost)

**If you want to change Atlas container port mapping** (change -p HOST_PORT:CONTAINER_PORT in the container command too)

- `HTTP_PORT` : http port to access Atlas application (default : 80)
- `HTTPs_PORT` : https port to access Atlas application default : 443)
- `SSH_PORT` : port number to ssh to the container (default : 22)
- `MYSQL_PASSWORD` : root mysql password (default : mysql)
