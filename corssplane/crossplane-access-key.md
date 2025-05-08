To securely set up AWS access credentials for Crossplane using the Upbound AWS provider, follow these steps:

✅ Step-by-Step: Set Up AWS Access Key for Crossplane

🔹 1. Create AWS Access Key
In the AWS Console or CLI:

aws iam create-access-key --user-name crossplane-user
Take note of:

Access Key ID
Secret Access Key
🎯 It’s best practice to create a dedicated IAM user with least privilege.

🔹 2. Create Kubernetes Secret with Credentials
kubectl create secret generic aws-creds \
  -n crossplane-system \
  --from-literal=credentials="[default]
aws_access_key_id=YOUR_ACCESS_KEY_ID
aws_secret_access_key=YOUR_SECRET_ACCESS_KEY"
Replace the placeholders accordingly.

🔹 3. Create ProviderConfig for AWS
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: aws-creds
      key: credentials
Apply it:

kubectl apply -f aws-providerconfig.yaml

🔹 4. Verify
Check the Crossplane provider logs for any errors:

kubectl get managed
kubectl get provider.pkg
kubectl logs -n crossplane-system deploy/provider-aws