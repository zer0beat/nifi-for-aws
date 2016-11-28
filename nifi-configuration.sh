#!/bin/bash

echo "JAVA_HOME=${JAVA_HOME}"
echo "VERSION=${VERSION}"
echo "NIFI_HOME=${NIFI_HOME}"
echo "STACKNAME=${STACKNAME}"
echo "REGION=${REGION}"

echo "NiFi ${VERSION} configuration script"

echo "Configure ${NIFI_HOME}/bin/nifi-env.sh"
echo "export JAVA_HOME=${JAVA_HOME}" >> ${NIFI_HOME}/bin/nifi-env.sh

#aws ec2 describe-instances --filters Name=state-reason-message,Values=running,Name=tag:App,Values='Apache NiFi',Name=tag:aws:cloudformation:stack-name,Values=nifi --region eu-west-1 --query 'Reservations[*].Instances[*].[AmiLaunchIndex,PrivateDnsName]' --output text

echo "Configure ${NIFI_HOME}/conf/zookeeper.properties"
i=1
for dnsName in $(aws ec2 describe-instances --filters Name=state-reason-message,Values=running,Name=tag:App,Values='Apache NiFi',Name=tag:aws:cloudformation:stack-name,Values=${STACKNAME} --region ${REGION} --query 'Reservations[*].Instances[*].[PrivateDnsName]' --output text)
do 
    echo "server.${i}=${dnsName}:2888:3888" >> ${NIFI_HOME}/conf/zookeeper.properties
    let "i += 1"
done

echo "Configure ${NIFI_HOME}/conf/nifi.properties"
sed -i "s/\(nifi\.state\.management\.embedded\.zookeeper\.start=\).*\$/\1true/" ${NIFI_HOME}/conf/nifi.properties

nifiZookeeperConnectString=$(aws ec2 describe-instances --filters Name=state-reason-message,Values=running,Name=tag:App,Values='Apache NiFi',Name=tag:aws:cloudformation:stack-name,Values=${STACKNAME} --region ${REGION} --query 'Reservations[*].Instances[*].[PrivateDnsName]' --output text | awk -F' ' '{print $1 ":2181"}' | xargs | sed 's/ /,/g')
sed -i "s/\(nifi\.zookeeper\.connect\.string=\).*\$/\1${nifiZookeeperConnectString}/" ${NIFI_HOME}/conf/nifi.properties
