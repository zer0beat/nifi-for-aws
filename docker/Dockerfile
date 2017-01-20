FROM        centos:latest
MAINTAINER  Arnau Sangrà <arnsangra@gmail.com>

ENV         NIFI_VERSION=1.1.1\
            NIFI_MIRROR=http://apache.rediris.es/nifi/1.1.1/nifi-1.1.1-bin.tar.gz\
            NIFI_HOME=/opt/nifi\
            JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.111-2.b15.el7_3.x86_64/jre

            # download & extract nifi
RUN         yum install -y java-1.8.0-openjdk tar && \
            mkdir -p /opt/nifi && \
            curl ${NIFI_MIRROR} | tar xvz -C ${NIFI_HOME} --strip-components=1

EXPOSE      8080 443

CMD ["/opt/nifi/bin/nifi.sh","run"]
