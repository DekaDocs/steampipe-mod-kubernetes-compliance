# 🚀 CloudekaGuard Compliance Workflow

A simple guide to get CloudekaGuard Kubernetes compliance checking up and running.

## 📋 Prerequisites Checklist

- [ ] Kubernetes cluster running
- [ ] CloudekaGuard CRDs installed in cluster
- [ ] `kubectl` configured and working
- [ ] Linux/macOS/WSL environment
- [ ] Internet connection for downloads

## ⚡ Quick Start (5 Minutes)

### Step 1: Install Required Tools

```bash
# Install Steampipe (data engine)
sudo /bin/sh -c "$(curl -fsSL https://steampipe.io/install/steampipe.sh)"

# Install PowerPipe (compliance engine)  
sudo /bin/sh -c "$(curl -fsSL https://powerpipe.io/install/powerpipe.sh)"

# Verify installations
steampipe --version
powerpipe --version
```

### Step 2: Get the Enhanced Plugin and Mod

```bash
# Create workspace directory
mkdir ~/cloudeka-compliance
cd ~/cloudeka-compliance

# Clone enhanced Kubernetes plugin (with CloudekaGuard support)
git clone https://github.com/YOUR_USERNAME/steampipe-plugin-kubernetes.git
cd steampipe-plugin-kubernetes

# Build and install plugin locally
make install-local

# Verify plugin installation
steampipe plugin list
# Should show: local/kubernetes | local | kubernetes

# Go back and clone the compliance mod
cd ~/cloudeka-compliance
git clone https://github.com/YOUR_USERNAME/steampipe-mod-kubernetes-compliance.git
cd steampipe-mod-kubernetes-compliance

# Install mod dependencies
powerpipe mod install
```

### Step 3: Configure Connection to Your Cluster

```bash
# Create Steampipe config directory
mkdir -p ~/.steampipe/config

# Create Kubernetes connection config
cat > ~/.steampipe/config/kubernetes.spc << EOF
connection "kubernetes" {
  plugin = "local/kubernetes"
  config_path = "~/.kube/config"
}
EOF
```

### Step 4: Start Services and Test

```bash
# Start Steampipe service
steampipe service start

# Test CloudekaGuard table access
steampipe query "SELECT count(*) FROM kubernetes_cloudeka_guard"
# Should return a number (0 if no CloudekaGuards exist)

# Test a simple compliance query
powerpipe query run query.cloudeka_guard_default_deny_ingress
```

### Step 5: Run Compliance Checks

```bash
# Run CloudekaGuard network policy compliance
powerpipe benchmark run cis_v170_5_3_2

# Launch web dashboard (optional)
powerpipe server
# Open http://localhost:9033 in browser
```

## 📊 Understanding Results

### Result Status Icons
- ✅ **OK** = Compliant (good!)
- ⚠️ **ALARM** = Non-compliant (needs fixing)
- ❌ **ERROR** = Technical issue
- ℹ️ **INFO** = Informational
- ➖ **SKIP** = Not applicable

### CloudekaGuard-Specific Results

```bash
# Good result - compliant namespace
✅ observability1 has 1 default deny ingress CloudekaGuard policies.

# Bad result - non-compliant namespace  
⚠️ production has 0 default deny ingress CloudekaGuard policies.

# Good result - restrictive policy
✅ deny-all-ingress does not allow all ingress traffic

# Bad result - permissive policy
⚠️ allow-all-policy allows all ingress traffic
```

## 🎯 Creating Compliant CloudekaGuard Policies

### Deny All Ingress (Required for Compliance)

```yaml
apiVersion: tenants.cloudeka.ai/v1alpha2
kind: CloudekaGuard
metadata:
  name: deny-all-ingress
  namespace: YOUR_NAMESPACE
spec:
  endpointSelector:
    matchLabels:
      namespace: YOUR_NAMESPACE
  ingress:
  - {}  # Empty object = deny all
```

### Deny All Egress (Required for Compliance)

```yaml
apiVersion: tenants.cloudeka.ai/v1alpha2
kind: CloudekaGuard
metadata:
  name: deny-all-egress
  namespace: YOUR_NAMESPACE
spec:
  endpointSelector:
    matchLabels:
      namespace: YOUR_NAMESPACE
  egress:
  - {}  # Empty object = deny all
```

### Apply Policies

```bash
kubectl apply -f deny-all-ingress.yaml
kubectl apply -f deny-all-egress.yaml

# Verify policies are created
kubectl get cloudekaguards -A
```

## 🔄 Regular Compliance Workflow

### Daily/Weekly Checks

```bash
# Navigate to mod directory
cd ~/cloudeka-compliance/steampipe-mod-kubernetes-compliance

# Run full compliance check
powerpipe benchmark run cis_v170 --output json --output-file compliance-$(date +%Y%m%d).json

# Check just network policies
powerpipe benchmark run cis_v170_5_3_2
```

### CI/CD Integration

```bash
#!/bin/bash
# compliance-check.sh

set -e

echo "🚀 Starting CloudekaGuard compliance check..."

# Run benchmark and capture exit code
if powerpipe benchmark run cis_v170_5_3_2 --output json --output-file compliance-results.json; then
    echo "✅ Compliance check passed!"
    exit 0
else
    echo "❌ Compliance check failed!"
    
    # Show failed controls
    jq -r '.groups[].controls[] | select(.status == "alarm") | .title' compliance-results.json
    
    exit 1
fi
```

## 🛠️ Troubleshooting Quick Fixes

### "No CloudekaGuard data found"

```bash
# Check cluster connection
kubectl get ns

# Check if CloudekaGuard CRDs exist  
kubectl get crd | grep cloudeka

# Check if any CloudekaGuards exist
kubectl get cloudekaguards -A

# Restart Steampipe service
steampipe service restart
```

### "Plugin not found errors"

```bash
# Reinstall plugin
cd ~/cloudeka-compliance/steampipe-plugin-kubernetes
make clean
make install-local
steampipe service restart
```

### "Connection errors"

```bash
# Check kubeconfig
kubectl config current-context

# Test basic Kubernetes query
steampipe query "SELECT count(*) FROM kubernetes_namespace"

# Check Steampipe config
cat ~/.steampipe/config/kubernetes.spc
```

## 📈 Monitoring Compliance Over Time

### Generate Historical Reports

```bash
# Weekly compliance report
powerpipe benchmark run cis_v170 \
  --output csv \
  --output-file "compliance-$(date +%Y-%U).csv"

# Monthly detailed report
powerpipe benchmark run cis_v170 \
  --output json \
  --output-file "compliance-$(date +%Y-%m).json"
```

### Track Policy Coverage

```bash
# Count CloudekaGuards per namespace
steampipe query "
SELECT 
    namespace,
    count(*) as cloudeka_guard_policies
FROM kubernetes_cloudeka_guard 
GROUP BY namespace
ORDER BY cloudeka_guard_policies DESC
"

# Find namespaces without policies
steampipe query "
SELECT 
    n.name as namespace,
    count(cg.name) as policy_count
FROM kubernetes_namespace n
LEFT JOIN kubernetes_cloudeka_guard cg ON n.name = cg.namespace
GROUP BY n.name
HAVING count(cg.name) = 0
"
```

## 🎯 Next Steps

1. **Set up automated compliance checking** in your CI/CD pipeline
2. **Create dashboard alerts** for compliance violations  
3. **Establish policy governance** for CloudekaGuard creation
4. **Train teams** on CloudekaGuard best practices
5. **Extend checks** for organization-specific requirements

## 📞 Getting Help

- Check the detailed [README_CLOUDEKA_GUARD.md](README_CLOUDEKA_GUARD.md) for advanced usage
- Review CloudekaGuard documentation for policy syntax
- Test with simple policies first before complex configurations
- Use `powerpipe benchmark run --help` for additional options

---

🎉 **Congratulations!** You now have CloudekaGuard-aware Kubernetes compliance checking running! 