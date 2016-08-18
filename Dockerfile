FROM paulbrown/base:latest

RUN yum upgrade -y -q
RUN yum install -y -q java-headless
RUN yum clean all

RUN curl http://apache.mirror.digitalpacific.com.au/zookeeper/zookeeper-3.5.2-alpha/zookeeper-3.5.2-alpha.tar.gz | tar -xzf - -C /opt
RUN mv /opt/zookeeper-3.5.2-alpha /opt/zookeeper

COPY zoo.cfg /opt/zookeeper/conf/zoo.cfg
COPY run.sh /run.sh

CMD /run.sh
