#!/bin/bash

HOSTNAME=$(curl -sL http://instance-data/latest/meta-data/hostname)
AMI_LAUNCH_INDEX=$(curl -sL http://instance-data/latest/meta-data/ami-launch-index)
COORDINATION_PORT=9999
SITE2SITE_PORT=9998

echo "##### Environment variables #####"
echo "  JAVA_HOME=${JAVA_HOME}"
echo "  VERSION=${VERSION}"
echo "  NIFI_HOME=${NIFI_HOME}"
echo "  STACKNAME=${STACKNAME}"
echo "  REGION=${REGION}"
echo "  HOSTNAME=${HOSTNAME}"
echo "  AMI_LAUNCH_INDEX=${AMI_LAUNCH_INDEX}"
echo "  COORDINATION_PORT=${COORDINATION_PORT}"
echo "  SITE2SITE_PORT=${SITE2SITE_PORT}"

echo "##### NiFi ${VERSION} configuration script #####"

echo "Configure ${NIFI_HOME}/bin/nifi-env.sh"
JAVA_HOME_ESCAPED=$(echo "$JAVA_HOME" | sed 's/\//\\\//g')
sed -i.backup -e "/^#.*JAVA_HOME/s/^#//" -e "s/\(.*JAVA_HOME=\).*/\1$JAVA_HOME_ESCAPED/" ${NIFI_HOME}/bin/nifi-env.sh

clusterNodes="$(aws ec2 describe-instances --filters Name=instance-state-name,Values=running Name=tag:App,Values='Apache NiFi' Name=tag:aws:cloudformation:stack-name,Values=${STACKNAME} --region ${REGION} --query 'Reservations[*].Instances[*].[AmiLaunchIndex,PrivateDnsName]' --output text)"

echo "Configure ${NIFI_HOME}/conf/zookeeper.properties"
sed -i.backup -e "/^server.1/ d" ${NIFI_HOME}/conf/zookeeper.properties
IFS=$'\n'
for node in ${clusterNodes}
do 
    echo ${node} | awk -F' ' '{print "server."$1+1"="$2":2888:3888" }' >> ${NIFI_HOME}/conf/zookeeper.properties
done

echo "Configure ${NIFI_HOME}/state/zookeeper/myid"
ZOOKEEPER_INDEX=$((AMI_LAUNCH_INDEX+1))
mkdir -p ${NIFI_HOME}/state/zookeeper
echo "${ZOOKEEPER_INDEX}" > ${NIFI_HOME}/state/zookeeper/myid

echo "Configure ${NIFI_HOME}/conf/nifi.properties"
nifiZookeeperConnectString=$(echo "${clusterNodes}" | awk -F' ' '{print $2":2181"}' | xargs | sed 's/ /,/g')
sed -i.backup \
    -e "s/\(nifi\.zookeeper\.connect\.string=\).*\$/\1${nifiZookeeperConnectString}/" \
    -e "s/\(nifi\.state\.management\.embedded\.zookeeper\.start=\).*\$/\1true/" \
    -e "s/\(nifi\.web\.http\.host=\).*\$/\1${HOSTNAME}/" \
    -e "s/\(nifi\.cluster\.is\.node=\).*\$/\1true/" \
    -e "s/\(nifi\.cluster\.node\.address=\).*\$/\1${HOSTNAME}/" \
    -e "s/\(nifi\.cluster\.node\.protocol\.port=\).*\$/\1${COORDINATION_PORT}/" \
    -e "s/\(nifi\.remote\.input\.host=\).*\$/\1${HOSTNAME}/" \
    -e "s/\(nifi\.remote\.input\.secure=\).*\$/\1false/" \
    -e "s/\(nifi\.remote\.input\.socket\.port=\).*\$/\1${SITE2SITE_PORT}/" \
    ${NIFI_HOME}/conf/nifi.properties