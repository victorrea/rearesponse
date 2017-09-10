#!/bin/bash
export AWS_DEFAULT_REGION=ap-southeast-2
STACKNAME=$1
TEMPLATE=$2
PARAMETERS=$3

IGNORE_ERROR="An error occurred (ValidationError) when calling the UpdateStack operation: No updates are to be performed."

if [[ -z ${STACKNAME} ]] || [[ -z ${TEMPLATE} ]] || [[ ! -f ${PARAMETERS} ]]; then
    echo "Usage: $0 <stackname> <template file> <parameters file>"
    exit 1
fi

set -x
aws cloudformation describe-stacks --stack-name ${STACKNAME} > /dev/null 2>&1

if [ $? -ne 0 ]; then
    # Create
    aws cloudformation create-stack --stack-name ${STACKNAME} \
                                    --template-body file://${TEMPLATE} \
                                    --parameters file://${PARAMETERS} \
                                    --capabilities CAPABILITY_IAM
    if [ $? -eq 0 ] ; then
        aws cloudformation wait stack-create-complete --stack-name ${STACKNAME}
    else
        echo "soemthing went wrong"
        return 1
    fi
else
    # Update
    UPDATE=$(aws cloudformation update-stack --stack-name ${STACKNAME} \
                                    --template-body file://${TEMPLATE} \
                                    --parameters file://${PARAMETERS} \
                                    --capabilities CAPABILITY_IAM 2>&1)

    RC=$?
    echo $UPDATE

    if [ $RC -eq 0 ] ; then
         aws cloudformation wait stack-update-complete --stack-name ${STACKNAME}
    elif [ "$(echo $UPDATE)" == "$(echo $IGNORE_ERROR)" ] ; then
         echo "No update to be made. Exiting gracefully"
         exit 0
    else
         exit $RC
    fi

fi
