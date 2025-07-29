# 🔍 How Steampipe + PowerPipe + CloudekaGuard Work Together

This document explains the architecture and workflow of using Steampipe and PowerPipe for CloudekaGuard compliance monitoring.

## 📋 Prerequisites

Before diving into the architecture, ensure you have:

- **Kubernetes Cluster**: Running with CloudekaGuard CRDs installed
- **kubectl**: Configured and working with your cluster
- **Go 1.23+**: Required for building the Steampipe plugin
- **Steampipe**: Data engine for Kubernetes API access
- **PowerPipe**: Compliance engine for running benchmarks
- **Git**: For cloning repositories
- **Linux/macOS/WSL**: Development environment

## 🏗️ Architecture Overview

### The Three-Layer Stack

```
┌─────────────────────────────────────────┐
│           📊 PowerPipe Layer            │
│   • Compliance benchmarks (CIS v1.7.0) │
│   • Controls (pass/fail logic)          │
│   • Queries (SQL compliance checks)     │
│   • Reports and dashboards              │
└─────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────┐
│          💾 Steampipe Database          │
│   • PostgreSQL-compatible interface    │
│   • Cached Kubernetes data as tables   │
│   • Real-time query capabilities       │
└─────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────┐
│          🔌 Steampipe Plugin            │
│   • Kubernetes API client              │
│   • CloudekaGuard CRD support          │
│   • Data transformation & caching      │
└─────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────┐
│         🔧 Kubernetes Cluster          │
│   • CloudekaGuard CRDs                 │
│   • Standard Kubernetes resources      │
│   • Your workloads and policies        │
└─────────────────────────────────────────┘
```

## ⚙️ Component Deep Dive

### 1. Steampipe Plugin (Data Collection Layer)

**What it does:**
- Connects to Kubernetes API using your kubeconfig
- Discovers and fetches CloudekaGuard custom resources
- Transforms Kubernetes objects into SQL-queryable tables
- Caches data for fast querying

**Key CloudekaGuard Enhancement:**
```go
// Enhanced table with CloudekaGuard spec data
func tableKubernetesCloudekaGuard() *plugin.Table {
    return &plugin.Table{
        Name: "kubernetes_cloudeka_guard",
        Columns: []*plugin.Column{
            {Name: "name", Type: proto.ColumnType_STRING},
            {Name: "namespace", Type: proto.ColumnType_STRING},
            {Name: "endpoint_selector", Type: proto.ColumnType_JSON}, // NEW
            {Name: "ingress", Type: proto.ColumnType_JSON},           // NEW
            {Name: "egress", Type: proto.ColumnType_JSON},            // NEW
        },
    }
}
```

**Data Flow:**
```
Kubernetes API → Plugin → SQL Table → Cache
```

### 2. Steampipe Database (Query Engine)

**What it does:**
- Provides PostgreSQL-compatible interface
- Serves cached Kubernetes data as SQL tables
- Handles complex queries and joins
- Updates data on-demand or via refresh

**Available Tables:**
```sql
-- Standard Kubernetes tables
kubernetes_namespace
kubernetes_pod
kubernetes_service
kubernetes_deployment

-- Enhanced CloudekaGuard table
kubernetes_cloudeka_guard  -- ✨ Our addition!
```

**Example Query:**
```sql
SELECT 
    name,
    namespace,
    endpoint_selector,
    ingress
FROM kubernetes_cloudeka_guard 
WHERE namespace = 'production';
```

### 3. PowerPipe Mod (Compliance Logic Layer)

**What it does:**
- Contains SQL queries that check compliance rules
- Defines controls (individual checks)
- Organizes controls into benchmarks (like CIS v1.7.0)
- Generates reports and dashboards

**CloudekaGuard Query Example:**
```sql
query "cloudeka_guard_default_deny_ingress" {
  sql = <<-EOQ
    with default_deny_count as (
      select
        ns.name as namespace,
        count(*) filter (
          where cg.ingress = '[{}]'::jsonb  -- Deny-all pattern
        ) as deny_policies
      from kubernetes_namespace ns
      left join kubernetes_cloudeka_guard cg on ns.name = cg.namespace
      group by ns.name
    )
    select
      namespace,
      case
        when deny_policies > 0 then 'ok'
        else 'alarm'
      end as status,
      namespace || ' has ' || deny_policies || ' deny-all ingress policies'
    from default_deny_count;
  EOQ
}
```

## 🔄 Data Flow Walkthrough

### Step-by-Step Process

1. **Data Collection (Steampipe Plugin)**
   ```
   Plugin → Kubernetes API → "List CloudekaGuards"
   Plugin → Extracts spec.ingress, spec.egress, spec.endpointSelector
   Plugin → Stores in kubernetes_cloudeka_guard table
   ```

2. **Query Execution (PowerPipe)**
   ```
   PowerPipe → Reads SQL query from mod
   PowerPipe → Executes query against Steampipe database
   PowerPipe → Gets CloudekaGuard + Namespace data
   PowerPipe → Applies compliance logic
   ```

3. **Compliance Evaluation**
   ```
   Query → Checks if ingress = '[{}]' (deny-all pattern)
   Query → Counts policies per namespace
   Query → Returns 'ok' or 'alarm' status
   ```

4. **Report Generation**
   ```
   PowerPipe → Collects all query results
   PowerPipe → Applies control logic (pass/fail)
   PowerPipe → Aggregates into benchmark scores
   PowerPipe → Generates reports (CLI/Web/JSON/PDF)
   ```

## 🧪 Real Example Walkthrough

Let's trace through a complete example:

### 1. You have this CloudekaGuard in your cluster:
```yaml
apiVersion: tenants.cloudeka.ai/v1alpha2
kind: CloudekaGuard
metadata:
  name: deny-all-ingress
  namespace: production
spec:
  endpointSelector:
    matchLabels:
      namespace: production
  ingress:
  - {}  # Deny-all pattern
```

### 2. Steampipe Plugin collects it:
```sql
-- Data appears in table as:
name: "deny-all-ingress"
namespace: "production"  
endpoint_selector: {"matchLabels":{"namespace":"production"}}
ingress: [{}]
egress: null
```

### 3. PowerPipe queries check compliance:
```sql
-- This query runs:
SELECT 
  namespace,
  count(*) FILTER (WHERE ingress = '[{}]'::jsonb) as deny_policies
FROM kubernetes_cloudeka_guard 
WHERE namespace = 'production'
GROUP BY namespace;

-- Result: production | 1
```

### 4. Control evaluates the result:
```hcl
control "cloudeka_guard_default_deny_ingress" {
  title = "Namespaces should have deny-all ingress CloudekaGuard"
  query = query.cloudeka_guard_default_deny_ingress
  
  # Query returned: namespace=production, deny_policies=1, status='ok'
}
```

### 5. Report shows compliance:
```
✅ production has 1 default deny ingress CloudekaGuard policies.
```

## 🎯 Why This Architecture Works

### Benefits of Separation

1. **Steampipe Plugin (Data)**:
   - Handles complex API interactions
   - Caches data for performance  
   - Provides consistent SQL interface
   - Can be reused across different compliance frameworks

2. **PowerPipe Mod (Logic)**:
   - Focus on compliance rules, not data collection
   - Easy to modify queries without rebuilding plugins
   - Version control for compliance policies
   - Shareable across organizations

### CloudekaGuard-Specific Advantages

1. **Custom Resource Support**: Plugin extracts CRD spec data that standard tools miss
2. **SQL Flexibility**: Complex compliance logic using familiar SQL syntax
3. **Real-time Checking**: Fresh data from cluster on each run
4. **Multi-format Output**: CLI, web dashboard, JSON, CSV, PDF reports

## 🔧 Customization Points

### Plugin Level (Go code)
```go
// Add new CloudekaGuard fields
{Name: "policy_version", Type: proto.ColumnType_STRING}
{Name: "labels", Type: proto.ColumnType_JSON}
```

### Mod Level (SQL + HCL)
```sql
-- Add custom compliance checks
query "your_custom_check" {
  sql = <<-EOQ
    SELECT * FROM kubernetes_cloudeka_guard 
    WHERE your_condition
  EOQ
}
```

```hcl
-- Add custom controls
control "your_custom_control" {
  title = "Your Custom Rule"
  query = query.your_custom_check
}
```

## 🚀 Performance Considerations

### Caching Strategy
- Plugin caches data in PostgreSQL
- Refresh on-demand or scheduled
- Fast queries without API calls

### Scalability  
- Handles large clusters (1000+ namespaces)
- Efficient SQL queries with indexes
- Parallel data collection

### Resource Usage
```bash
# Typical resource usage
Steampipe Plugin: ~50-100MB RAM
PostgreSQL Cache: ~100-500MB disk
PowerPipe Mod: ~10-20MB RAM
```

## 🎓 Summary

The enhanced architecture provides:

1. **🔌 Enhanced Plugin**: CloudekaGuard CRD support in Steampipe
2. **💾 SQL Interface**: Query CloudekaGuard policies like any database
3. **🧪 Compliance Logic**: PowerPipe mod with CloudekaGuard-aware checks
4. **📊 Multiple Outputs**: Dashboard, CLI, JSON, PDF reports
5. **🔧 Extensible**: Easy to add new checks and policies

This separation of concerns makes the system maintainable, testable, and adaptable to your organization's specific CloudekaGuard compliance requirements.

---

**Next**: Follow the [WORKFLOW.md](WORKFLOW.md) for step-by-step setup instructions! 