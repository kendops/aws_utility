# ✅ Stores AWS credentials in a hidden file
# ✅ Creates a Kubernetes secret for Crossplane
# ✅ Applies a ProviderConfig YAML to use the secret

#!/bin/bash

# ---------------- CONFIG ----------------
AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
CREDENTIALS_FILE="$HOME/.aws/.aws-crossplane-creds"
NAMESPACE="crossplane-system"
SECRET_NAME="aws-creds"
PROVIDER_CONFIG_FILE="providerconfig.yaml"

# ---------------- STEP 1: Save AWS credentials to hidden file ----------------
echo "📁 Creating hidden AWS credentials file..."
mkdir -p ~/.aws

cat > "$CREDENTIALS_FILE" <<EOF
[default]
aws_access_key_id=$AWS_ACCESS_KEY_ID
aws_secret_access_key=$AWS_SECRET_ACCESS_KEY
EOF

chmod 600 "$CREDENTIALS_FILE"
echo "✅ Credentials file saved at: $CREDENTIALS_FILE"

# ---------------- STEP 2: Create Kubernetes Secret ----------------
echo "🔐 Creating Kubernetes secret..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

kubectl delete secret $SECRET_NAME -n $NAMESPACE --ignore-not-found

kubectl create secret generic $SECRET_NAME \
  -n $NAMESPACE \
  --from-file=credentials="$CREDENTIALS_FILE"

echo "✅ Secret '$SECRET_NAME' created in namespace '$NAMESPACE'."

# ---------------- STEP 3: Generate and Apply ProviderConfig ----------------
echo "⚙️ Generating ProviderConfig manifest..."

cat > "$PROVIDER_CONFIG_FILE" <<EOF
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: $NAMESPACE
      name: $SECRET_NAME
      key: credentials
EOF

kubectl apply -f "$PROVIDER_CONFIG_FILE"
echo "✅ ProviderConfig 'default' applied."

# ---------------- DONE ----------------
echo "🎉 Crossplane AWS credentials setup complete!"

# chmod +x setup-crossplane-aws-creds.sh
# ./setup-crossplane-aws-creds.sh
