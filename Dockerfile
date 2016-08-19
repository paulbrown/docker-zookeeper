FROM docker.io/paulbrown/base:latest

RUN yum upgrade --quiet --assumeyes

RUN yum install --quiet --assumeyes java-headless

RUN yum clean all

RUN curl --silent --show-error http://apache.mirror.digitalpacific.com.au/zookeeper/zookeeper-3.5.2-alpha/zookeeper-3.5.2-alpha.tar.gz | tar -xzf - -C /opt

RUN mv /opt/zookeeper-3.5.2-alpha /opt/zookeeper

EXPOSE 2181 2888 3888

COPY zoo.cfg /opt/zookeeper/conf/zoo.cfg

VOLUME /data


