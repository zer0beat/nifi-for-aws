#!/bin/bash

echo "JAVA_HOME=${JAVA_HOME}"
echo "VERSION=${VERSION}"
echo "NIFI_HOME=${NIFI_HOME}"

echo "NiFi ${VERSION} configuration script"

echo "Configure ${NIFI_HOME}/bin/nifi-env.sh"
echo "export JAVA_HOME=${JAVA_HOME}" > ${NIFI_HOME}/bin/nifi-env.sh



