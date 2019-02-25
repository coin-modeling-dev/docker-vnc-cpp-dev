
### Dockerfile
Build a container with this Dockerfile to create a nice desktop with sudo privileges.  It is based on the image `consol/ubuntu-xfce-vnc`.  There are other Linux distros supported. See the [consol docker hub](https://hub.docker.com/r/consol/ubuntu-xfce-vnc/).  

To keep things simple, let's just apply naming conventions based on the value of $USER.

First, ensure you are in the group `docker` by checking `id -Gn`. 
To add yourself to the group: `sudo usermod -a -G docker ${USER}` (you will need to log out and log back in to activate the new membership).

Your main decision: Use a new docker volume? Or use a home directory?  I elected to use a new docker volume.  On the other hand, if you use a directory as a volume then you can access your old files from the new image.
* Use a new docker volume: `docker volume create vol-${USER} && export VOLUME="vol-${USER}"`
* Use your home directory: `export VOLUME="/home/${USER}"`

Build container:
* Get your UID, using `id -u` and GID, using `id -g`
* Edit the Dockerfile and put in your username, UID, and GID.
* Add packages if you want.  This file downloads clion and installs it in /opt
* Build the container `$ docker build -t vnc-${USER} -f Dockerfile.user ./`

Run your container:
* First, find a number `N` that is not used for a vnc server.
* Start the server with a docker volume

    `docker run 
       --cap-add sys_ptrace 
       -p 590<N>:5901 
       --name vnc-${USER} 
       --mount source=${VOLUME},target=/home/${USER}
       -e VNC_PW=<your password> 
       -e VNC_RESOLUTION=1280x1024 
	     vnc-${USER}`
* ... or alternatively with a disk partition:
    `docker run 
       --cap-add sys_ptrace 
       -p 590<N>:5901 
       --name vnc-${USER} 
       -v/my/existing/disk/path:/home/${USER}
       -e VNC_PW=<your password> 
       -e VNC_RESOLUTION=1280x1024 
	      vnc-${USER}`

* Connect using VNC client to port `590<N>` with password `<your password>`
* Note that you are a sudo user so you can add packages, etc. 
* But if you find yourself adding lots of packages, then maybe you want to put them into the Dockerfile

Check on things:
* To see if your container is running: 
`docker ps -a | grep $USER`
* If you need to kill your container (say, because you really should have used a docker volume): 
`docker stop vnc-${USER} && docker rm vnc-${USER}`
This is preferred to just hitting `ctrl-c` because it will recycle the vnc port you are using.


