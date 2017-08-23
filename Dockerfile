FROM paulbrown/base:latest

ENV ZK_USER=zookeeper \
	ZK_HOME=/opt/zookeeper \
	ZK_DATA_DIR=/var/lib/zookeeper/data \
	ZK_DATA_LOG_DIR=/var/lib/zookeeper/log \
	ZK_LOG_DIR=/var/log/zookeeper \
	JAVA_HOME= /usr/bin/java \
	PATH=$PATH:$ZK_HOME/bin

ARG ZK_DIST=zookeeper-3.5.3-beta

RUN yum update --assumeyes \
    && yum install --assumeyes java-1.8.0-openjdk-headless nmap-ncat wget \
	&& wget --quiet "http://www.apache.org/dist/zookeeper/$ZK_DIST/$ZK_DIST.tar.gz" \
    && wget --quiet "http://www.apache.org/dist/zookeeper/$ZK_DIST/$ZK_DIST.tar.gz.asc" \
    && wget --quiet "http://www.apache.org/dist/zookeeper/KEYS" \
    && export GNUPGHOME="$(mktemp --directory)" \
    && gpg --import KEYS \
    && gpg --batch --verify "$ZK_DIST.tar.gz.asc" "$ZK_DIST.tar.gz" \
    && tar --extract --file="$ZK_DIST.tar.gz"  --directory=/opt \
    && rm --recursive --force "$GNUPGHOME" "$ZK_DIST.tar.gz" "$ZK_DIST.tar.gz.asc" \
    && ln --symbolic /opt/$ZK_DIST $ZK_HOME \
    && rm --recursive --force /opt/zookeeper/CHANGES.txt \
		/opt/zookeeper/README.txt \
		/opt/zookeeper/NOTICE.txt \
		/opt/zookeeper/CHANGES.txt \
		/opt/zookeeper/README_packaging.txt \
		/opt/zookeeper/build.xml \
		/opt/zookeeper/config \
		/opt/zookeeper/contrib \
		/opt/zookeeper/dist-maven \
		/opt/zookeeper/docs \
		/opt/zookeeper/ivy.xml \
		/opt/zookeeper/ivysettings.xml \
		/opt/zookeeper/recipes \
		/opt/zookeeper/src \
		/opt/zookeeper/$ZK_DIST.jar.asc \
		/opt/zookeeper/$ZK_DIST.jar.md5 \
		/opt/zookeeper/$ZK_DIST.jar.sha1 \
	&& yum erase --assumeyes wget \
	&& yum clean all

#Copy configuration generator script to bin
COPY zkGenConfig.sh zkOK.sh zkMetrics.sh "$ZK_HOME/bin/"

# Create a user for the zookeeper process and configure file system ownership 
# for nessecary directories and symlink the distribution as a user executable
RUN useradd $ZK_USER \
	&& usermod --uid 1000 $ZK_USER \
	&& groupmod --gid 1000 $ZK_USER \
    && mkdir --parents $ZK_DATA_DIR $ZK_DATA_LOG_DIR $ZK_LOG_DIR /usr/share/zookeeper /tmp/zookeeper /usr/etc/ \
	&& chown --recursive "$ZK_USER:$ZK_USER" /opt/$ZK_DIST $ZK_DATA_DIR $ZK_LOG_DIR $ZK_DATA_LOG_DIR /tmp/zookeeper \
	&& ln --symbolic /opt/zookeeper/conf/ /usr/etc/zookeeper \
	&& ln --symbolic /opt/zookeeper/bin/* /usr/bin \
	&& ln --symbolic /opt/zookeeper/$ZK_DIST.jar /usr/share/zookeeper/ \
	&& ln --symbolic /opt/zookeeper/lib/* /usr/share/zookeeper 