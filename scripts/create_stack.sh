#!/bin/bash

## DEF. SETTINGS:
AWS_REGION_CONFIG=$(grep "region" $HOME/.aws/config)
AWS_REGION_CONFIG=${AWS_REGION_CONFIG##'region = '}

DEFAULT_REGION=${AWS_REGION_CONFIG:='eu-west-1'}
DEFAULT_STACK_NAME='nifi-test'
DEFAULT_KEY_NAME='ggc-automation'
DEFAULT_GIT_BRANCH='master'
DEFAULT_CLUSTER_SIZE=3
DEFAULT_CLOUDFORMATION_TEMPLATE='../nifi-for-aws.template'


## INTERACTIVE CONF:
read -e -p "CloudFormation Template: " -i "$DEFAULT_CLOUDFORMATION_TEMPLATE" input
CLOUDFORMATION_TEMPLATE=${input:=$DEFAULT_CLOUDFORMATION_TEMPLATE}

read -e -p "AWS Region: " -i "$DEFAULT_REGION" input
REGION=${input:=$DEFAULT_REGION}

read -e -p "CloudFormation Stack Name: " -i "$DEFAULT_STACK_NAME" input
STACK_NAME=${input:=$DEFAULT_STACK_NAME}

read -e -p "Key Name: " -i "$DEFAULT_KEY_NAME" input
KEY_NAME=${input:=$DEFAULT_KEY_NAME}

read -e -p "Git Branch Base: " -i "$DEFAULT_GIT_BRANCH" input
GIT_BRANCH=${input:=$DEFAULT_GIT_BRANCH}

read -e -p "Cluster nodes: " -i "$DEFAULT_CLUSTER_SIZE" input
CLUSTER_SIZE=${input:=$DEFAULT_CLUSTER_SIZE}

echo

if [[ $VERBOSE ]]; then
    printf "\n%s\n" "Final configuration:"
    printf "\t- %s\n" $REGION
    printf "\t- %s\n" $STACK_NAME
    printf "\t- %s\n" $KEY_NAME
    printf "\t- %s\n" $GIT_BRANCH
    printf "\t- %s\n" $CLUSTER_SIZE
fi

echo "Launching NIFI cluster with supplied parameters.."

aws cloudformation create-stack --stack-name $STACK_NAME --template-body file://${CLOUDFORMATION_TEMPLATE} --region $REGION --parameters ParameterKey=KeyName,ParameterValue=$KEY_NAME ParameterKey=GitBranch,ParameterValue=$GIT_BRANCH ParameterKey=ClusterSize,ParameterValue=$CLUSTER_SIZE --capabilities CAPABILITY_NAMED_IAM
