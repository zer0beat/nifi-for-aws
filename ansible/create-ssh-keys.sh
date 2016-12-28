#!/bin/bash

HOSTNAME=$(curl -sL http://instance-data/latest/meta-data/hostname)
AMI_LAUNCH_INDEX=$(curl -sL http://instance-data/latest/meta-data/ami-launch-index)

echo "##### Environment variables #####"
echo "  GIT_BRANCH=${GIT_BRANCH}"
echo "  STACKNAME=${STACKNAME}"
echo "  REGION=${REGION}"
echo "  HOSTNAME=${HOSTNAME}"
echo "  AMI_LAUNCH_INDEX=${AMI_LAUNCH_INDEX}"

# Download generic keys
mkdir -p /root/unsecure/
curl -o /root/unsecure/id_rsa -L https://github.com/zer0beat/nifi-for-aws/raw/${GIT_BRANCH}/ansible/sshkeys/id_rsa
chmod 0600 /root/unsecure/id_rsa
curl -o /root/unsecure/id_rsa.pub -L https://github.com/zer0beat/nifi-for-aws/raw/${GIT_BRANCH}/ansible/sshkeys/id_rsa.pub
chmod 0644 /root/unsecure/id_rsa.pub
cat /root/unsecure/id_rsa.pub >> /root/.ssh/authorized_keys

if [[ "$AMI_LAUNCH_INDEX" == "0" ]]
then
    echo "##### Create SSH keys #####"
    clusterNodes="$(aws ec2 describe-instances --filters Name=instance-state-name,Values=running Name=tag:App,Values='Apache NiFi' Name=tag:aws:cloudformation:stack-name,Values=${STACKNAME} --region ${REGION} --query 'Reservations[*].Instances[*].[PrivateDnsName]' --output text)"

    # Wait to other instances
    for node in ${clusterNodes}
    do 
        until ssh -oStrictHostKeyChecking=no -i /root/unsecure/id_rsa -q ${node} exit
        do
            sleep 10
        done
    done

    # Create and share ssh keys on all instances
    IFS=$'\n'
    for node in ${clusterNodes}
    do 
        ssh -i /root/unsecure/id_rsa ${node} "ssh-keygen -f /home/centos/.ssh/id_rsa -t rsa -N '' && chown centos:centos /home/centos/.ssh/id_rsa*"
        pubkey=$(ssh -i /root/unsecure/id_rsa ${node} "cat /home/centos/.ssh/id_rsa.pub")
        for innerNode in ${clusterNodes}
        do 
            ssh -oStrictHostKeyChecking=no -i /root/unsecure/id_rsa ${innerNode} "echo ${pubkey} >> /home/centos/.ssh/authorized_keys" 
        done
    done

    # Delete initial keys on non 0 indexed instance
    for node in ${clusterNodes}
    do 
        if ! [[ "$HOSTNAME" == "$node" ]]
        then
            ssh -oStrictHostKeyChecking=no -i /root/unsecure/id_rsa ${node} "rm -rf /root/unsecure && sed -i -e \"/\$ansible-init/ d\" /root/.ssh/authorized_keys" 
        fi
    done

    # Delete initial keys on 0 indexed instance
    rm -rf /root/unsecure
    sed -i -e "/$ansible-init/ d" /root/.ssh/authorized_keys
fi