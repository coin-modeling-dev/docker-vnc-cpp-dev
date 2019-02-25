FROM consol/ubuntu-xfce-vnc

#Define user
ENV USER=kingaj
ENV UID=1001
ENV GID=1001

# Create user and add to sudoer group
USER root
RUN useradd -m $USER && \
        echo "$USER:$USER" | chpasswd && \
        usermod --shell /bin/bash $USER && \
        usermod -aG sudo $USER && \
        echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USER && \
        chmod 0440 /etc/sudoers.d/$USER && \
        usermod  --uid ${UID} $USER && \
        groupmod --gid ${GID} $USER

#### Install any build packages
RUN apt-get update -y && \
        apt-get install -y --no-install-recommends \
                build-essential \
                cmake \
                gdb \
                gfortran \
                libblas-dev \
                libboost-all-dev \
                libc6-dbg \
                libeigen3-dev \
                libhdf5-dev \
                liblapack-dev \
                libsuitesparse-dev libtrilinos-zoltan-dev \
                mpi-default-dev \
                pgf \
                pkg-config \
                software-properties-common \
		            sudo \
                valgrind \
                wget && \
        apt-get clean && \
        apt-get autoremove -y && \
        rm -rf /var/lib/apt/lists/*

#### Install CLion
ENV CL_VERSION="CLion-2019.1"
RUN wget https://download.jetbrains.com/cpp/${CL_VERSION}.tar.gz -O /tmp/clion.tar.gz &&\
	mkdir -p /opt/clion && \
        tar zxvf /tmp/clion.tar.gz --strip-components=1 -C /opt/clion && \
        rm -f /tmp/clion.tar.gz
		
	
### Switch to user 
USER ${USER}
