#!/usr/bin/env bash
# shellcheck shell=bash
# Copyright 2016 Amazon.com, Inc. or its affiliates.
# All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#    http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file.
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
# either express or implied. See the License for the specific language governing permissions
# and limitations under the License.
source ./setup.sh

echo "Running lambda function: ${file_posting_broker_lambda_function_name}"
test_event='{name: blah.tar.gz}'
payload=`echo '{"name": "blah.tar.gz" }' | openssl base64`

rm -f invoke-lambda.out;
aws lambda invoke \
  --function-name ${file_posting_broker_lambda_function_arn} \
  --region ${deployment_region} \
  --log-type Tail \
  --payload ${payload} \
  --query 'LogResult' --output text invoke-lambda.out |  base64 -d

echo -e "\n** Return Output **\n"
cat invoke-lambda.out
echo -e "\n********************\n"
