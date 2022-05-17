#!/bin/bash
# Navigate to the root of the repository and run:
# bash scripts/git-setup.sh
# Requires AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html

set -euo pipefail

# Variables:
source scripts/deployment-variables.sh

# Get parameters from stack
USER=$(aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query "Stacks[*].Outputs[?OutputKey=='IAMUserName'].OutputValue" --output text)
CODECOMMIT_SSH_URL=$(aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query "Stacks[*].Outputs[?OutputKey=='RepoCloneUrlSsh'].OutputValue" --output text)

# Generate ssh key
SSH_KEY_LOC=~/.ssh/cicd-serverless
rm -f $SSH_KEY_LOC
rm -f $SSH_KEY_LOC.pub
ssh-keygen -q -f $SSH_KEY_LOC -t rsa -N ''

# Upload ssh key to IAM
SSH_PUB_KEY_ID=$(aws iam upload-ssh-public-key --user-name $USER --ssh-public-key-body file://$SSH_KEY_LOC.pub --query "SSHPublicKey.SSHPublicKeyId" --output text)
ssh-add $SSH_KEY_LOC

echo "waiting 15 sec for the uploaded key to be applied"
sleep 15

mkdir $LOCAL_REPO_FOLDER

# Clone repo and push initial commit
FULL_CODECOMMIT_SSH_URL=${CODECOMMIT_SSH_URL/ssh:\/\//ssh:\/\/$SSH_PUB_KEY_ID@}
echo "Run: git clone $FULL_CODECOMMIT_SSH_URL"
git clone $FULL_CODECOMMIT_SSH_URL $LOCAL_REPO_FOLDER

# Then add your files and commit
# Using the sample project in this Quick Start
cp -R sample-project/* $LOCAL_REPO_FOLDER/

cd $LOCAL_REPO_FOLDER
git add .
git commit -m "initial commit"
git push
