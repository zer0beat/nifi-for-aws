#!/bin/bash
STACKNAME=$1
NAR_PATH=$2
REGION="eu-west-1"
FILENAME="nifi-adapter.nar"
CREDENTIALS="/mnt/c/Development/big-data/ggc-automation.pem"
USER="centos"
IFS=$'\n'

source colors.sh

clusterNodes="$(aws ec2 describe-instances --filters Name=instance-state-name,Values=running Name=tag:App,Values='Apache NiFi' Name=tag:aws:cloudformation:stack-name,Values=${STACKNAME} --region ${REGION} --query 'Reservations[*].Instances[*].[AmiLaunchIndex,PublicDnsName]' --output text)"

function ifSucceedPrint {
    if [ $? -eq 0 ]; then
        printf $1
    fi
}

function getIpFromNode {
    echo "$(echo $1 | awk -F' ' '{print $2}')"
}


function stopNifiCluster {
    printf "${BIRed}     Stopping nifi service\n${Color_Off}"
    for node in ${clusterNodes}
    do
        ip=$(getIpFromNode $node)
        ssh -i $CREDENTIALS $USER@$ip 'sudo service nifi stop'
        ifSucceedPrint "${Red}Serivce stopped in node ${ip}\n${Color_Off}"
    done
}

function startNifiCluster {
    printf "${BIGreen}     Starting nifi service\n${Color_Off}" 
    for node in ${clusterNodes}
    do
        ip=$(getIpFromNode $node)
        ssh -i $CREDENTIALS $USER@$ip 'sudo service nifi start'
        ifSucceedPrint "${Green}Serivce started in node ${ip}\n${Color_Off}"
    done
}


function copyNarToNifiNodes {
    printf "${BIYellow}     Copying .nar file to nodes\n${Color_Off}"
    for node in ${clusterNodes}
    do
        ip=$(getIpFromNode $node)
        scp -i $CREDENTIALS $NAR_PATH ${USER}@${ip}:/home/${USER}/${FILENAME}
        ssh -i $CREDENTIALS ${USER}@${ip} "sudo mv /home/centos/${FILENAME} /opt/nifi/lib/"
        ifSucceedPrint "${Yellow}Coppied .nar file in node ${ip}\n${Color_Off}"
        #ssh -i $CREDENTIALS ${USER}@${ip} "sudo rm /opt/nifi/lib/${FILENAME}"
        #ifSucceedPrint "${Yellow}Removed .nar file in node ${ip}\n${Color_Off}"
    done
}

stopNifiCluster
copyNarToNifiNodes
startNifiCluster

