#!/bin/bash

command=$1
config=$2
opt=$3
. atlas.cfg

cd "$(dirname "$0")"

docker_min_version='0.9.1'
docker_rec_version='0.11.1'

config_file=containers/"$config".yml
cidfile=cids/"$config".cid
cidbootstrap=cids/"$config"_boostrap.cid
test_image=ubuntu:14.04
image=alexisduque/openmrs:atlas_base
image_atlas=alexisduque/openmrs:atlas

docker_path=`which docker.io || which docker`

docker_ip=`/sbin/ifconfig | \
                grep -B1 "inet addr" | \
                awk '{ if ( $1 == "inet" ) { print $2 } else if ( $2 == "Link" ) { printf "%s:" ,$1 } }' | \
                grep docker0 | \
                awk -F: '{ print $3 }';`


usage () {
  echo "Usage: launcher COMMAND CONFIG [--skip-prereqs]"
  echo "Commands:"
  echo "    start:      Start/initialize a container"
  echo "    stop:       Stop a running container"
  echo "    restart:    Restart a container"
  echo "    destroy:    Stop and remove a container"
  echo "    ssh:        Start a bash shell in a running container"
  echo "    logs:       Docker logs for container"
  echo "    build:      Build a container"
  echo "    update:     Destroy and build an Atlas App container based on atlas_base"
  echo "    rebuild:    Rebuild a container (destroy old, bootstrap, start new)"
  echo
  echo "Options:"
  echo "    --skip-prereqs   Don't check prerequisites"
  exit 1
}

compare_version() {
    declare -a ver_a
    declare -a ver_b
    IFS=. read -a ver_a <<< "$1"
    IFS=. read -a ver_b <<< "$2"

    while [[ -n $ver_a ]]; do
        if (( ver_a > ver_b )); then
            return 0
        elif (( ver_b > ver_a )); then
            return 1
        else
            unset ver_a[0]
            ver_a=("${ver_a[@]}")
            unset ver_b[0]
            ver_b=("${ver_b[@]}")
        fi
    done
    return 1  # They are equal
}

prereqs() {

  # 1. docker daemon running?
  test=`$docker_path info >/dev/null`

  if [[ $? -ne 0 ]] ; then
    echo "Cannot connect to the docker daemon - verify it is running and you have access"
    exit 1
  fi

  # 2. running aufs 
  test=`$docker_path info 2> /dev/null | grep 'Driver: aufs'`
  if [[ "$test" =~ "aufs" ]] ; then : ; else
    echo "Your Docker installation is not using aufs, in the past we have had issues with it"
    echo "If you are unable to bootstrap your image (or stop it) please report the issue at:"
    echo "https://meta.discourse.org/t/discourse-docker-installation-without-aufs/15639"
  fi

  # 3. running recommended docker version
  test=($($docker_path --version))  # Get docker version string
  test=${test[2]//,/}  # Get version alone and strip comma if exists

  [[ "$test" =~ "0.12.0" ]] && echo "You are running a broken version of Docker, please upgrade ASAP. See: https://meta.discourse.org/t/the-installation-stopped-in-the-middle/16311/ for more details." && exit 1

  # At least minimum version
  if compare_version "${docker_min_version}" "${test}"; then
    echo "ERROR: Docker version ${test} not supported, please upgrade to at least ${docker_min_version}, or recommended ${docker_rec_version}"
    exit 1
  fi

  # Recommend best version
  if compare_version "${docker_rec_version}" "${test}"; then
    echo "WARNING: Docker version ${test} deprecated, recommend upgrade to ${docker_rec_version} or newer."
  fi

  # 4. able to attach stderr / out / tty
  test=`$docker_path run -i --rm -a stdout -a stderr $test_image echo working`
  if [[ "$test" =~ "working" ]] ; then : ; else
    echo "Your Docker installation is not working correctly"
    echo
    echo "See: https://meta.discourse.org/t/docker-error-on-bootstrap/13657/18?u=sam"
    exit 1
  fi
}

if [ "$opt" != "--skip-prereqs" ] ; then
  prereqs
fi

get_ssh_pub_key() {
  if tty -s ; then
    if [[ ! -e ~/.ssh/id_rsa.pub && ! -e ~/.ssh/id_dsa.pub ]] ; then
      echo "This user has no SSH key, but a SSH key is required to access the Discourse Docker container."
      read -p "Generate a SSH key? (Y/n) " -n 1 -r
      if [[ $REPLY =~ ^[Nn]$ ]] ; then
        echo
        echo WARNING: You may not be able to log in to your container.
        echo
      else
        echo
        echo Generating SSH key
        mkdir -p ~/.ssh && ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
        echo
      fi
    fi
  fi

  ssh_pub_key="$(cat ~/.ssh/id_rsa.pub 2>/dev/null || cat ~/.ssh/id_dsa.pub)"
}


install_docker() {

  echo "Docker is not installed, make sure you are running on the 3.8 kernel"
  echo "The best supported Docker release is Ubuntu 12.04.03 for it run the following"
  echo
  echo "sudo apt-get update"
  echo "sudo apt-get install linux-image-generic-lts-raring linux-headers-generic-lts-raring"
  echo "sudo reboot"
  echo

  echo "sudo sh -c \"wget -qO- https://get.docker.io/gpg | apt-key add -\""
  echo "sudo sh -c \"echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list\""
  echo "sudo apt-get update"
  echo "sudo apt-get install lxc-docker"

  exit 1
}

run_stop(){
  if [ ! -e $cidfile ]
     then
       echo "No cid found"
       exit 1
     else
       $docker_path stop -t 10 `cat $cidfile`
  fi
}

run_start(){

  if [ ! -e $cidfile ]
     then
       echo "No cid found, creating a new container"
       ports="-p $SSH_PORT:22 -p $HTTP_PORT:80"

       existing=`$docker_path ps -a | awk '{ print $1, $(NF) }' | grep "$config$" | awk '{ print $1 }'`
       if [ ! -z $existing ]
       then
         echo "Found an existing container by its name, recovering cidfile, please rerun"
         echo $existing > $cidfile
         exit 1
       fi
       echo $docker_path run "${env[@]}" -h $HOST -e DOCKER_HOST_IP=$docker_ip --name $config -t --cidfile $cidfile $ports $image_atlas
       $docker_path run "${env[@]}" -h $HOST -e DOCKER_HOST_IP=$docker_ip --name $config -t --cidfile $cidfile $ports $image_atlas
       exit 0
     else
       cid=`cat $cidfile`

       if [ -z $cid ]
       then
         echo "Detected empty cid file, deleting, please re-run"
         rm $cidfile
         exit 1
       fi

       found=`$docker_path ps -q -a --no-trunc | grep $cid`
       if [ -z $found ]
       then
         echo "Invalid cid file, deleting, please re-run"
         rm $cidfile
         exit 1
       fi

       echo "cid found, ensuring container is started"
       $docker_path start `cat $cidfile`
       exit 0
  fi

}

run_build(){
  get_ssh_pub_key
  if [ -f image/atlas_base/auth_key.pub ]
  then 
    rm image/atlas_base/auth_key.pub
  fi
  if [ -f image/atlas_20/atlas.cfg ]
  then 
    image/atlas_20/atlas.cfg
  fi
  cp atlas.cfg image/atlas_20/atlas.cfg
  echo $ssh_pub_key > image/atlas_base/auth_key.pub
  # Is the image available?
  # If not, pull it here so the user is aware what's happening.
  $docker_path history $image >/dev/null 2>&1 || $docker_path pull $image

  rm -f $cidbootstrap

  env=("${env[@]}" "-e" "SSH_PUB_KEY=$ssh_pub_key")

  $docker_path build -t $image ./image/atlas_base && \
  $docker_path build -t $image_atlas ./image/atlas_20
}

run_update(){
  if [ -e $cidfile ]
  then
    echo "destroying container $cidfile"
    $docker_path stop -t 10 `cat $cidfile`
    $docker_path rm `cat $cidfile` && rm $cidfile
  else
    echo "nothing to destroy cidfile does not exist"
  fi
  get_ssh_pub_key
  $docker_path history $image_atlas >/dev/null 2>&1 && $docker_path rmi -f $image_atlas 

  if [ -f image/atlas_20/atlas.cfg ]
  then 
    image/atlas_20/atlas.cfg
  fi
  cp atlas.cfg image/atlas_20/atlas.cfg

  # Is the image available?
  # If not, pull it here so the user is aware what's happening.
  $docker_path history $image >/dev/null 2>&1 || $docker_path build -t $image ./image/atlas_base && \

  rm -f $cidbootstrap

  env=("${env[@]}" "-e" "SSH_PUB_KEY=$ssh_pub_key")

  $docker_path build -t $image_atlas ./image/atlas_20 || { echo 'Command failed' ; exit 1; }

}

case "$command" in
  build)
      run_build
      echo "Successfully bootstrapped, to startup use ./launcher start $config"
      exit 0
      ;;

  ssh)
      if [ ! -e $cidfile ]
         then
           echo "No cid found"
           exit 1
         else
           cid="`cat $cidfile`"
           address="`$docker_path port $cid 22`"
           split=(${address//:/ })
           exec ssh -o StrictHostKeyChecking=no root@${split[0]} -p ${split[1]}
      fi
      ;;

  stop)
      run_stop
      exit 0
      ;;

  logs)

      if [ ! -e $cidfile ]
         then
           echo "No cid found"
           exit 1
         else
           $docker_path logs `cat $cidfile`
           exit 0
      fi
      ;;

  restart)
      run_stop
      run_start
      exit 0
      ;;

  start)
      run_start
      exit 0
      ;;

  rebuild)
      if [ -e $cidfile ]
        then
          echo "Stopping old container"
          $docker_path stop -t 10 `cat $cidfile`
      fi

      run_build

      if [ -e $cidfile ]
        then
          $docker_path rm `cat $cidfile` && rm $cidfile
      fi

      run_start
      exit 0
      ;;

  update)
      if [ -e $cidfile ]
        then
          echo "Stopping old container"
          $docker_path stop -t 10 `cat $cidfile`
      fi

      run_update
      
      if [ -e $cidfile ]
        then
          $docker_path rm `cat $cidfile` && rm $cidfile
      fi
      exit 0
      ;;


  destroy)
      if [ -e $cidfile ]
        then
          echo "destroying container $cidfile"
          $docker_path stop -t 10 `cat $cidfile`
          $docker_path rm `cat $cidfile` && rm $cidfile
          exit 0
        else
          echo "nothing to destroy cidfile does not exist"
          exit 1
      fi
      ;;
esac

usage
