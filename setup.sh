#!/usr/bin/env bash
# shellcheck disable=SC2034

export AWS_PROFILE="dave-personal"
# root of project directory...assumes setup.sh is in project root
# /mnt/c/Users/david/Dropbox/Programming/Python/PyCharmProjects/usaid-ghsc-bia-djh/
# root_dir=$(pwd)
root_dir="/mnt/c/Users/david/Dropbox/Programming/Python/PyCharmProjects/AWS_Serverless/usaid_bia_v2"


echo "Root directory: ${root_dir}"
foundation_dir=${root_dir}/foundation
refdata_dir=${root_dir}/refdata
docs_dir=${root_dir}/docs
logs_dir=${root_dir}/logs
scripts_dir=${root_dir}/scripts
sample_data_dir=${root_dir}/sample_data
tests_dir=${root_dir}/tests

# set AWS Account ID
aws_account_id=$(aws sts get-caller-identity --query 'Account' --output text --profile ${AWS_PROFILE})
deployment_region="us-east-1"

# Settings for S3 Bucket to manage CloudFormation, etc. resources.
s3_config_stack_name="usaid-bia-s3-code-config-djh"
s3_code_config_template_file="s3-code-config.cft"
# TODO: The S3 bucket name is set in the cft file...if this is ever needed it should be retrieved from the cfn output.
s3_code_config_bucket_name="usaid-ghsc-bia-s3-code-config-dev-${aws_account_id}"
s3_code_prefix="usaid-bia"

# Foundation stack details
foundation_stack_name="usaid-bia-foundation-djh"
foundation_template_file="${foundation_dir}/foundation.yaml"
foundation_output_template_file="${foundation_dir}/foundation_packaged.yaml"

file_posting_broker_lambda_function_name="file_posting_broker"
file_posting_broker_lambda_function_arn="arn:aws:lambda:us-east-1:612530344502:function:file_posting_broker"

ingestion_cfn_output_template_file="${root_dir}/ingestion_packaged-template.yaml"

ingestion_stack_name="ingest-ghsc-psm-artmis"

date_time=$(date +'%Y_%m_%d_%H_%M_%S')
