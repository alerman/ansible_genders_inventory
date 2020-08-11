FROM centos:centos7

# Install software
RUN yum -y clean all && \
    yum -y install java-1.8.0-openjdk-devel wget net-tools && \
    yum -y install yum-utils device-mapper-persistent-data lvm2 && \
    yum -y install which && \
    yum -y install autoconf && \
    yum -y install make gcc-c++ openssl-libs openssl-devel libcurl-devel expat-devel gettext-devel zlib-devel && \
    yum -y install epel-release && \
    yum -y install python-pip && \
    pip install --upgrade pip && \
    yum -y install yum-utils && \
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
    yum -y install docker-ce docker-ce-cli containerd.io docker-compose && \
    yum -y install https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm && \
    yum -y install git && \
    git --version && \
    yum -y clean all


ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk

# Simple smoke testing
RUN java -version 2>&1 >/dev/null && \
    which git && \
    which docker && \
    which docker-compose

ENTRYPOINT ["/bin/bash", "-l", "-c"]