**Crossplane manifest** to provision** ****up to 3 EC2 instances** using the** ** **AWS provider** . This example assumes:

* You have already installed the Crossplane AWS provider (`provider-aws`)
* AWS provider credentials have been configured via a** **`ProviderConfig`
* You want a maximum of 3 nodes (e.g., for a small cluster)

---

### ✅ Step-by-Step: EC2 Instance Provisioning with Crossplane (max 3 nodes)

🔹** **`providerConfig.yaml`

apiVersion: aws.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: aws-provider
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: aws-creds
      key: creds

### 🔹** **`ec2-instance-class.yaml`

(Defines how EC2 instances will be configured)

apiVersion: compute.aws.crossplane.io/v1beta1
kind: EC2Instance
metadata:
  name: ec2-node
spec:
  forProvider:
    region: us-east-2
    instanceType: t3.medium
    keyName: devbox-key
    subnetIdSelector:
      matchLabels:
        role: public
    securityGroupIdSelector:
      matchLabels:
        role: public
    amiId: ami-0c55b159cbfafe1f0  # Replace with latest RHEL/Ubuntu
    tags:
      - key: Name
        value: crossplane-node
  providerConfigRef:
    name: aws-provider

### 🔹** **`composite-resource.yaml` (Optional abstraction layer)

For reusable infrastructure definitions, use XRD + Composition (not shown here unless requested).

---

### 🔹** **`kustomization.yaml` (to apply replicas)

Use** **`kustomize` or ArgoCD to scale the instances.
