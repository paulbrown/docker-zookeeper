#!/bin/bash

# Small hack to get id until PetSet index is made available through 
# Downward API (kubernetes issues #30427 #31218).
T_HOSTNAME=$(hostname)
T_ID=$( echo ${T_HOSTNAME} | cut -d "-" -f2 | cut -d "-" -f1 )

# Allow time for our container to register with DNS.
sleep 10

# Get our 'zookeeper' peers through nslookup. This is locked to a service
# name exposed as 'zookeeper'. Could do better here and make nslookup more
# dynamic using a variable that contains the service name. 
# TODO: Have a bootstrap image that contains bind-utils and also knows
# the service name, performs nslookup and passes the list of PEERS to this
# script. We can then remove bind-utils from the zookeeper container image.  
PEERS=( $(nslookup -type=srv zookeeper.default | grep -oE '[^ ]+$' | grep ^zookeeper*) )

# Output content of PEERS array to container log.
echo "Zookeeper PEERS:" ${PEERS[@]}

# No DNS PEERS, setup a default localhost else build PEERS config.
if [ ${#PEERS[@]} -eq 0 ]; then
  echo "server.0=localhost:2888:3888:participant;2181" >> /opt/zookeeper/conf/zoo.cfg.dynamic
  T_MEMBERS="server.0=localhost:2888:3888:participant;2181"
else
  for PEER in "${PEERS[@]}"
  do
    P_HOSTNAME=$( echo ${PEER} | cut -d "." -f1 )
    P_ID=$( echo ${P_HOSTNAME} | cut -d "-" -f2 | cut -d "-" -f1 )
    P_MEMBER="server.${P_ID}=${PEER}:2888:3888:participant;2181"
    echo ${P_MEMBER} >> /opt/zookeeper/conf/zoo.cfg.dynamic
    T_MEMBERS=${T_MEMBERS},${P_MEMBER}
  done
fi

# Trim any leading comma and output MEMBERS to container log. 
MEMBERS=${T_MEMBERS#\,}
echo "Zookeeper MEMBERS:" ${MEMBERS}

# Initialize, start zookeeper, add members as participant through zkCli, stop. 
# Finally start-foreground to keep container running.
/opt/zookeeper/bin/zkServer-initialize.sh --force --myid=${T_ID}
/opt/zookeeper/bin/zkServer.sh start /opt/zookeeper/conf/zoo.cfg
/opt/zookeeper/bin/zkCli.sh reconfig -members ${MEMBERS} quit
/opt/zookeeper/bin/zkServer.sh stop
exec /opt/zookeeper/bin/zkServer.sh start-foreground /opt/zookeeper/conf/zoo.cfg
