FROM waystonesystems/baseimage-centos:0.2.0
RUN yum install -y java-1.8.0-openjdk-devel make gcc-c++ wget git epel-release tigervnc-server net-tools && yum -y clean all 
#Have to skip broken here as something above (or centos) installs python 2.7, and some packages  in the group say they need pythin2.6
RUN yum -y groupinstall "Server with GUI" --skip-broken && yum -y clean all
RUN yum -y groupinstall "MATE" && yum -y clean all
RUN yum -y upgrade firefox git java && yum -y clean all
ADD ./dependencies/apache-maven-3.5.4-bin.tar.gz /opt/maven
ADD ./dependencies/ideaIC-2018.1.3-no-jdk.tar.gz /opt/idea
RUN ln -s /opt/idea/idea-IC-181.4892.42 /opt/idea/current
RUN ln -s /opt/maven/apache-maven-3.5.4 /opt/maven/current
ENV M2_HOME="/opt/maven/current/"
ENV JAVA_HOME=""
RUN yum install -y yum-utils \
      device-mapper-persistent-data \
      lvm2 && yum-config-manager \
                  --add-repo \
                  https://download.docker.com/linux/centos/docker-ce.repo \
                  && yum -y install docker-ce && yum -y clean all

#Set up MATE
RUN echo "mate-session" > ~/.Xclients
RUN chmod +x ~/.Xclients

#Expose VNC server port
EXPOSE 5901

ENTRYPOINT ["bash"]

