#!/bin/bash

echo "JAVA_HOME=${JAVA_HOME}"
echo "VERSION=${VERSION}"
echo "NIFI_HOME=${NIFI_HOME}"

echo "NiFi ${VERSION} configuration script"

echo "Configure ${NIFI_HOME}/bin/nifi-env.sh"
echo "export JAVA_HOME=${JAVA_HOME}" >> ${NIFI_HOME}/bin/nifi-env.sh

#aws ec2 describe-instances --filters Name=tag:App,Values='Apache NiFi',Name=tag:aws:cloudformation:stack-name,Values=nifi --region eu-west-1
#aws ec2 describe-instances --filters Name=tag:App,Values='Apache NiFi',Name=tag:aws:cloudformation:stack-name,Values=nifi --region eu-west-1 --query 'Reservations[*].Instances[*].[InstanceId]' --output text
#aws ec2 describe-instances --filters Name=tag:App,Values='Apache NiFi',Name=tag:aws:cloudformation:stack-name,Values=nifi --region eu-west-1 --query 'Reservations[*].Instances[*].[PrivateDNSName]' --output text




