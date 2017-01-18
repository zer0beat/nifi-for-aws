#! /bin/bash

internal_nodes=$(grep "connect.string" /opt/nifi/conf/nifi.properties | cut -d '=' -f 2)
internal_nodes="$(echo $internal_nodes | egrep -o '[-.[:alnum:]]{5,}')"
nifi_properties_file="/opt/nifi/conf/nifi.properties"
certificate="CN=bigdata,OU=ApacheNiFi"
	echo "nodes found:"
for i in $internal_nodes; do
	printf "\t --> %s\n" $i;
done

toolkit_mirror='http://apache.mirrors.hoobly.com/nifi/1.1.1/nifi-toolkit-1.1.1-bin.tar.gz'
toolkit_filename=${toolkit_mirror##*/}
dir=`mktemp -d --tmpdir` && cd $dir

printf "%s %s\n" "Downloading Apache Toolkit into" $dir
curl -o $toolkit_filename $toolkit_mirror
sudo tar -zxf $toolkit_filename -C /opt/nifi --strip-components 1


printf  "%s\n" "Create trustores, certificate and keystore..."
hostnames=""
for i in $internal_nodes; do
	hostnames="${hostnames}-n $i "
done

echo "sudo /opt/nifi/bin/tls-toolkit.sh standalone ${hostnames} -C ${certificate} -o \"$dir\" -f $nifi_properties_file"
sudo /opt/nifi/bin/tls-toolkit.sh standalone ${hostnames} -C ${certificate} -o "$dir" -f $nifi_properties_file

#-ip-172-31-117-45.eu-west-1.compute.internal,ip-172-31-117-46.eu-west-1.compute.internal


echo "Deleting temporal folder..."
#rm -rf $dir
