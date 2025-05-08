https://github.com/crossplane/crossplane/tree/main/cluster/charts/crossplane

# Install Crossplane

curl -sL "https://raw.githubusercontent.com/crossplane/crossplane/main/install.sh" | sh

```
kubectl create namespace crossplane-system
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane --namespace crossplane-system crossplane-stable/crossplane
```

# Check Crossplane Status

```
helm list -n crossplane-system
kubectl get all -n crossplane-system
```

# Install Crossplane CLI

```
curl -sL https://raw.githubusercontent.com/crossplane/crossplane/master/install.sh | sh
```
