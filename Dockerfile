FROM paulbrown/base:latest

ENV ZK_USER=zk \
  ZK_HOME=/zk \
  ZK_DATADIR=/zk_data \
  ZK_DATALOGDIR=/zk_datalog \
  ZK_LOG_DIR=/zk_log

ARG ZK_DIST=zookeeper-3.5.3-beta

RUN set -o pipefail \
  && yum update --assumeyes \
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
  && rm --recursive --force $ZK_HOME/CHANGES.txt \
    $ZK_HOME/README.txt \
    $ZK_HOME/NOTICE.txt \
    $ZK_HOME/CHANGES.txt \
    $ZK_HOME/README_packaging.txt \
    $ZK_HOME/build.xml \
    $ZK_HOME/config \
    $ZK_HOME/contrib \
    $ZK_HOME/dist-maven \
    $ZK_HOME/docs \
    $ZK_HOME/ivy.xml \
    $ZK_HOME/ivysettings.xml \
    $ZK_HOME/recipes \
    $ZK_HOME/src \
    $ZK_HOME/$ZK_DIST.jar.asc \
    $ZK_HOME/$ZK_DIST.jar.md5 \
    $ZK_HOME/$ZK_DIST.jar.sha1 \
  && yum erase --assumeyes wget \
  && yum clean all

#Copy configuration generator and setup scripts to bin
COPY zkGenConfig.sh zkOK.sh zkMetrics.sh "$ZK_HOME/bin/"

# Create a user for the zookeeper process and configure file system ownership 
# for nessecary directories and symlink the distribution as a user executable
RUN set -o pipefail \ 
  && groupadd --gid 1000 $ZK_USER \
  && useradd --uid 1000 --gid $ZK_USER --home $ZK_HOME $ZK_USER \
  && mkdir --parents $ZK_DATADIR $ZK_DATALOGDIR $ZK_LOG_DIR \
  && chown -R -L -h "$ZK_USER:$ZK_USER" $ZK_HOME $ZK_DATADIR $ZK_DATALOGDIR $ZK_LOG_DIR
 
# Set working directory to home
WORKDIR $ZK_HOME

# Set non-root user on container start
USER 1000