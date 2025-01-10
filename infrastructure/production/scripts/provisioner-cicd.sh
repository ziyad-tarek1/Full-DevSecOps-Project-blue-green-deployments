#!/bin/bash

# Variables
AWS_REGION="us-east-1"  # Set your AWS region
CLUSTER_NAME="my-eks"  # Replace with your EKS cluster name

# Configure AWS CLI credentials
AWS_ACCESS_KEY_ID="********************"  # Replace with your Access Key ID
AWS_SECRET_ACCESS_KEY="******************"  # Replace with your Secret Access Key
AWS_CLI_CONFIG_FILE="/home/ubuntu/.aws/credentials"

# Create AWS CLI configuration directory
mkdir -p /home/ubuntu/.aws

# Write credentials to AWS CLI configuration file
cat <<EOL > $AWS_CLI_CONFIG_FILE
[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
region = $AWS_REGION
EOL

# Update kubeconfig for EKS
aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION

# Make sure the credentials and kubeconfig file are owned by ubuntu
chown -R ubuntu:ubuntu /home/ubuntu/.aws
