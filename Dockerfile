FROM poklet/centos-baseimage

RUN yum install -y java-1.8.0-openjdk-devel make gcc-c++ wget git epel-release tigervnc-server net-tools
#HAve to skip broken here as something above (or centos) installs python 2.7, and some packages  in the group say they need pythin2.6
RUN yum -y groupinstall "Server with GUI" --skip-broken
RUN yum -y groupinstall "MATE Desktop"
ADD ./cloudera-cdh5.repo /etc/yum.repos.d/cloudera-cdh5.repo
ADD ./dependencies/apache-maven-3.5.3-bin.tar.gz /opt/maven
ADD ./dependencies/ideaIC-2018.1.3.tar.gz /opt/idea
ENV PATH="/opt/maven/apache-maven-3.5.3/bin:${PATH}"
ENV M2_HOME="/opt/maven"
ENV JAVA_HOME=""
RUN rpm --import https://archive.cloudera.com/cdh5/redhat/7/x86_64/cdh/RPM-GPG-KEY-cloudera
RUN yum -y install zookeeper
RUN yum clean all
RUN mkdir -p /var/lib/zookeeper && chown -R zookeeper /var/lib/zookeeper/
RUN yum -y install hadoop hadoop-0.20-mapreduce hadoop-client
RUN yum -y install hadoop-hdfs-namenode hadoop-hdfs-secondarynamenode hadoop-hdfs-datanode
RUN yum -y install hadoop-yarn-resourcemanager hadoop-yarn-nodemanager hadoop-mapreduce-historyserver

#RUN zookeeper-server-initialize && zookeeper-server start

ENTRYPOINT ["bash"]

