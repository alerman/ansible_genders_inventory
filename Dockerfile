FROM poklet/centos-baseimage

RUN yum install -y java-1.8.0-openjdk-devel make gcc-c++ wget git
ADD ./cloudera-cdh5.repo /etc/yum.repos.d/cloudera-cdh5.repo
ADD ./dependencies/apache-maven-3.5.3-bin.tar.gz /opt/maven

RUN rpm --import https://archive.cloudera.com/cdh5/redhat/7/x86_64/cdh/RPM-GPG-KEY-cloudera
RUN yum -y install zookeeper
RUN yum clean all
RUN mkdir -p /var/lib/zookeeper && chown -R zookeeper /var/lib/zookeeper/
RUN yum -y install hadoop hadoop-0.20-mapreduce hadoop-client
RUN yum -y install hadoop-hdfs-namenode hadoop-hdfs-secondarynamenode hadoop-hdfs-datanode
RUN yum -y install hadoop-yarn-resourcemanager hadoop-yarn-nodemanager hadoop-mapreduce-historyserver

#RUN zookeeper-server-initialize && zookeeper-server start

ENTRYPOINT ["bash"]

