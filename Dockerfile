FROM docker.io/paulbrown/base:latest

RUN yum upgrade --quiet --assumeyes && yum clean all

RUN yum install --quiet --assumeyes java-headless && yum clean all

RUN curl --silent --show-error http://apache.mirror.digitalpacific.com.au/zookeeper/zookeeper-3.5.2-alpha/zookeeper-3.5.2-alpha.tar.gz | tar -xzf - -C /opt

RUN mv /opt/zookeeper-3.5.2-alpha /opt/zookeeper

COPY zoo.cfg /opt/zookeeper/conf/zoo.cfg

EXPOSE 2181 2888 3888

VOLUME /data

COPY onStart.sh /onStart.sh

RUN chmod +x /onStart.sh




