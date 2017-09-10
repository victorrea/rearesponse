# REA Systems Engineer practical task
## Requirements for running
- This solution will deploy the application in AWS, so need AWS account (allowed to run CloudFormation and create EC2 resources), a Ubuntu base image.
- Other tooling pre-installed:
  - Execute from Linux (I'm using Ubuntu).
  - awscli, jq - e.g. In Ubuntu, they can ben installed as below:
    ```
    $ sudo apt-get update
    $ sudo apt-get install -y awscli jq
    $ aws configure
      ......
    ```
  - packer - download from [here](https://releases.hashicorp.com/packer/1.0.4/packer_1.0.4_linux_amd64.zip) and extract, add the directory to PATH

## Instructions for the reviewer
- Update configuration:
  - update Ubuntu base image in packer template `bakeami.json` (I'm using Amazon's Ubuntu Server 16.04 LTS):

    `e.g. "source_ami": "ami-e2021d81",`
  - update VPC, subnet and ssh key name in CloudFormation Parameters file `cloudformation/cfn_parameter.json`:
    - VPC ID:

      `e.g. {
      "ParameterKey": "VpcID",
      "ParameterValue": "vpc-5fd18f3b"
    },`
    - subnet ID for the EC2 instance (it needs to hava internet gateway):

      `e.g. {
      "ParameterKey": "SubnetID",
      "ParameterValue": "subnet-da09eabd"
    }`
    - EC2 ssh key name to access the EC2 instance:

      `e.g. {
      "ParameterKey": "KeyName",
      "ParameterValue": "victortest"
    }`
  - update allowed IP range for EC2 instance SSH access in CloudFormation template `cloudformation/cfn_template.yaml`:

    `e.g. IpRanges:
    Standard:
      AdminAccess: 49.177.107.199/32`
- Execution:

  Inside the folder, run the following command (and it can be run repeatedly):
  ```
  $ ./deploy.sh
  ```
  It will execute the following steps:
  1. Bake custom Ubuntu AMI via packer - it will update OS packages, install git/curl/ruby and install bundle/rack gems.
  1. Get your latest custom AMI (by defined Tags) and update AMI ID in CloudFormation parameters file.
  1. Deploy the application via Cloudformation which provisions the following: (create a new stack if this is the first time, or update stack if it's already there)
      - SecurityGroup for EC2 instance to allow public access to port 80 and admin access to ssh port 22
      - One EC2 instance using the custom Ubuntu AMI - deploy the application from github, start it to port 80 and redirect logging to a local file
      - Output the EC2 instance PublicDnsName
  1. Test if the application is running (by curl the PublicDnsName)

# Explanation of assumptions and design choices
  The basic idea is to create immutable infrastructure:
  - Use packer to bake a "standard" AMI, which can also be used by other similar ruby applications
  - Use CloudFormation to do continuous deployment(so the old instances will be disposed), parameterise inputs so that the template can be re-used as well
  - Staged deployment steps, which can be easily integrated into CI/CD tools (e.g. Jenkins)
  - Regression test is integrated into the deployment pipeline


  Other improvements - Because it's only required to provision one application server, so I just create one EC2 instance. But in reality, probably we need to:
  - put EC2 instances into multi-AZ AutoScalingGroup and configure AutoScaling rules
  - put ELB before EC2 instances and move EC2 instances to private subnets, so that web traffic goes to ELB instead of instances directly
  - create CloudFront distruibution and WAF rules

  Then we can have a more secure and resilient environment.
