#!/bin/bash

# Packer build AMI
packer build bakeami.json

# Get latest AMI ID and update CloudFormation parameters file
./get_ami.sh

# Deploy app via cloudformation
./create_or_update_stack.sh myteststack cloudformation/cfn_template.yaml cloudformation/cfn_parameter.json

# Simple test
./curltest.sh
