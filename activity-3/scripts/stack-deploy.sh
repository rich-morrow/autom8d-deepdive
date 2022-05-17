#!/bin/bash
# Navigate to the root of the repository and run:
# bash scripts/stack-deploy.sh
# Requires AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html

####### IMPORTANT #######
# This script is not required by the quick start. 
# It is included as an alternative way to deploy this quick start.

set -euo pipefail

# Variables:
source scripts/deployment-variables.sh

# Create S3 bucket for CloudFormation sub-templates
echo "Creating S3 bucket and uploading sub-templates"
aws s3 mb s3://${S3_BUCKET}

# Upload templates to S3
aws s3 cp ./ s3://${S3_BUCKET}/${S3_PREFIX} --recursive

# Deploy Quick Start CloudFormation stack
echo "Deploying CloudFormation stack"
aws cloudformation deploy \
    --template-file ./templates/full-stack.template.yaml \
    --stack-name ${STACK_NAME} \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides DevAwsAccountId=${DEV_ACCOUNT_ID} ProdAwsAccountId=${PROD_ACCOUNT_ID} QSS3BucketName=${S3_BUCKET} QSS3KeyPrefix="${S3_PREFIX}/"
echo "Deploy successful"
