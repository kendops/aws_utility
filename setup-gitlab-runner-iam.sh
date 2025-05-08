### Here's a complete bash script to automate the creation of:

# An IAM policy
# An IAM role with EC2 trust policy
# An instance profile
# And attachment of that profile to an existing EC2 instance

#!/bin/bash

# ---------------- CONFIG ----------------
ROLE_NAME="gitlab-runner-role"
POLICY_NAME="gitlab-runner-policy"
INSTANCE_PROFILE_NAME="gitlab-runner-profile"
INSTANCE_ID="i-0bf7b862acd32c260"  # <-- Replace with your actual EC2 instance ID
REGION="us-east-2"

# Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# ---------------- STEP 1: Create IAM Policy ----------------
cat > gitlab-runner-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "s3:*",
        "eks:*",
        "iam:PassRole",
        "cloudformation:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF

aws iam create-policy \
  --policy-name $POLICY_NAME \
  --policy-document file://gitlab-runner-policy.json 2>/dev/null

# ---------------- STEP 2: Create Trust Policy and IAM Role ----------------
cat > trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

aws iam create-role \
  --role-name $ROLE_NAME \
  --assume-role-policy-document file://trust-policy.json 2>/dev/null

# ---------------- STEP 3: Attach Policy to Role ----------------
POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}"

aws iam attach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn $POLICY_ARN

# ---------------- STEP 4: Create Instance Profile and Attach Role ----------------
aws iam create-instance-profile \
  --instance-profile-name $INSTANCE_PROFILE_NAME 2>/dev/null

aws iam add-role-to-instance-profile \
  --instance-profile-name $INSTANCE_PROFILE_NAME \
  --role-name $ROLE_NAME

# ---------------- STEP 5: Wait for propagation ----------------
echo "Waiting for instance profile to become available..."
sleep 10
aws iam get-instance-profile \
  --instance-profile-name $INSTANCE_PROFILE_NAME > /dev/null

# ---------------- STEP 6: Associate Profile with EC2 Instance ----------------
aws ec2 associate-iam-instance-profile \
  --instance-id $INSTANCE_ID \
  --iam-instance-profile Name=$INSTANCE_PROFILE_NAME

# ---------------- DONE ----------------
echo "✅ GitLab Runner IAM Role and Instance Profile setup complete!"

### 🧪 To Run:
# 1. Save as setup-gitlab-runner-iam.sh
# 2. Make it executable:
# 3. chmod +x setup-gitlab-runner-iam.sh

# Run it:
# ./setup-gitlab-runner-iam.sh
