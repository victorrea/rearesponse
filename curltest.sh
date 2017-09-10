#!/bin/bash
result=$(curl -s $(aws cloudformation describe-stacks --stack-name myteststack --query Stacks[*].Outputs[*].OutputValue --output text))
echo $result
if [ "$result" == "Hello World!" ]; then
  echo "Your app is up and running."
else
  echo "Something went wrong with your app."
  return 1
fi
