# Kubernetes Compliance Mod for Powerpipe

Multiple checks covering industry defined security best practices for Kubernetes. The mod supports parsing and analyzing Kubernetes manifest files, allowing you to assess compliance directly on your configuration files before deployment. Includes support for CIS, National Security Agency (NSA) and Cybersecurity and Infrastructure Security Agency (CISA) Cybersecurity technical report for Kubernetes hardening.

## 🚀 Enhanced: CloudekaGuard Support

This enhanced version includes **native support for CloudekaGuard CRDs** - perfect for Kubernetes clusters using Cilium and KubeOVN with CloudekaGuard for advanced network policy management.

### 📋 Prerequisites for CloudekaGuard Support

- **Go 1.23+**: Required for building the enhanced Steampipe plugin
- **Kubernetes Cluster**: With CloudekaGuard CRDs installed
- **kubectl**: Configured and working with your cluster

### 📚 CloudekaGuard Quick Start Guides

- **🏃 [5-Minute Setup](WORKFLOW.md)** - Get CloudekaGuard compliance running quickly
- **🔍 [Architecture Guide](HOW_IT_WORKS.md)** - Understanding Steampipe + PowerPipe + CloudekaGuard
- **📖 [Complete Documentation](README_CLOUDEKA_GUARD.md)** - Comprehensive CloudekaGuard guide

### ✨ What's New in This Version

- **🔌 Enhanced Kubernetes Plugin**: Extracts CloudekaGuard CRD specifications (`endpoint_selector`, `ingress`, `egress`)
- **📊 CloudekaGuard Compliance Queries**: Native SQL queries for CloudekaGuard policy analysis
- **🛡️ CIS v1.7.0 Network Policy Updates**: Now uses CloudekaGuard instead of standard NetworkPolicy for section 5.3
- **📈 Multi-format Reports**: CLI, web dashboard, JSON, CSV, and PDF outputs with CloudekaGuard-specific results

Run checks in a dashboard:
![image](https://raw.githubusercontent.com/turbot/steampipe-mod-kubernetes-compliance/main/docs/kubernetes_nsa_csa_v1.png)

Or in a terminal:
![image](https://raw.githubusercontent.com/turbot/steampipe-mod-kubernetes-compliance/main/docs/kubernetes_compliance_mod_console_output.png)

## Documentation

- **[Benchmarks and controls →](https://hub.powerpipe.io/mods/turbot/kubernetes_compliance/controls)**
- **[Named queries →](https://hub.powerpipe.io/mods/turbot/kubernetes_compliance/queries)**

## Getting Started

### Installation

Install Powerpipe (https://powerpipe.io/downloads), or use Brew:

```sh
brew install turbot/tap/powerpipe
```

This mod also requires [Steampipe](https://steampipe.io) with the [Kubernetes plugin](https://hub.steampipe.io/plugins/turbot/kubernetes) as the data source. Install Steampipe (https://steampipe.io/downloads), or use Brew:

```sh
brew install turbot/tap/steampipe
steampipe plugin install kubernetes
```

Steampipe will automatically use your default Kubernetes credentials. Optionally, you can [setup multiple context connections](https://hub.steampipe.io/plugins/turbot/kubernetes#multiple-context-connections) or [customize Kubernetes credentials](https://hub.steampipe.io/plugins/turbot/kubernetes#configuring-kubernetes-cluster-credentials).

Finally, install the mod:

```sh
mkdir dashboards
cd dashboards
powerpipe mod init
powerpipe mod install github.com/turbot/steampipe-mod-kubernetes-compliance
```

### Browsing Dashboards

Start Steampipe as the data source:

```sh
steampipe service start
```

Start the dashboard server:

```sh
powerpipe server
```

Browse and view your dashboards at **http://localhost:9033**.

### Running Checks in Your Terminal

Instead of running benchmarks in a dashboard, you can also run them within your
terminal with the `powerpipe benchmark` command:

List available benchmarks:

```sh
powerpipe benchmark list
```

Run a benchmark:

```sh
powerpipe benchmark run kubernetes_compliance.benchmark.cis_v170
```

Different output formats are also available, for more information please see
[Output Formats](https://powerpipe.io/docs/reference/cli/benchmark#output-formats).

### Common and Tag Dimensions

The benchmark queries use common properties (like `connection_name`, `context_name`, `namespace`, `path` and `source_type`) and tags that are defined in the form of a default list of strings in the `variables.sp` file. These properties can be overwritten in several ways:

It's easiest to setup your vars file, starting with the sample:

```sh
cp powerpipe.ppvars.example powerpipe.ppvars
vi powerpipe.ppvars
```

Alternatively you can pass variables on the command line:

```sh
powerpipe benchmark run kubernetes_compliance.benchmark.cis_v170 --var 'tag_dimensions=["Environment", "Owner"]'
```

Or through environment variables:

```sh
export PP_VAR_common_dimensions='["connection_name", "context_name", "namespace", "path", "source_type"]'
export PP_VAR_tag_dimensions='["Environment", "Owner"]'
powerpipe benchmark run kubernetes_compliance.benchmark.cis_v170
```

## Open Source & Contributing

This repository is published under the [Apache 2.0 license](https://www.apache.org/licenses/LICENSE-2.0). Please see our [code of conduct](https://github.com/turbot/.github/blob/main/CODE_OF_CONDUCT.md). We look forward to collaborating with you!

[Steampipe](https://steampipe.io) and [Powerpipe](https://powerpipe.io) are products produced from this open source software, exclusively by [Turbot HQ, Inc](https://turbot.com). They are distributed under our commercial terms. Others are allowed to make their own distribution of the software, but cannot use any of the Turbot trademarks, cloud services, etc. You can learn more in our [Open Source FAQ](https://turbot.com/open-source).

## Get Involved

**[Join #powerpipe on Slack →](https://turbot.com/community/join)**

Want to help but don't know where to start? Pick up one of the `help wanted` issues:

- [Powerpipe](https://github.com/turbot/powerpipe/labels/help%20wanted)
- [Kubernetes Compliance Mod](https://github.com/turbot/steampipe-mod-kubernetes-compliance/labels/help%20wanted)
