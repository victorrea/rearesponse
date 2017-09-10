#!/bin/bash

export LATEST_AMI=$(aws ec2 describe-images --owners self  --filters "Name=tag:Name,Values=simple-sinatra" | jq --raw-output '.Images|=sort_by(.CreationDate)|.Images|=reverse|.Images[0].ImageId')
echo $LATEST_AMI
newconf=$(jq -e --arg newami $LATEST_AMI '[.[]|select(.ParameterKey=="AMIParam").ParameterValue=$newami]' cloudformation/cfn_parameter.json)
echo $newconf > cloudformation/cfn_parameter.json
