locals {
  cis_v170_5_common_tags = merge(local.cis_v170_common_tags, {
    cis_section_id = "5"
  })
}

locals {
  cis_v170_5_1_common_tags = merge(local.cis_v170_5_common_tags, {
    cis_section_id = "5.1"
  })

  cis_v170_5_2_common_tags = merge(local.cis_v170_5_common_tags, {
    cis_section_id = "5.2"
  })

  cis_v170_5_3_common_tags = merge(local.cis_v170_5_common_tags, {
    cis_section_id = "5.3"
  })

  cis_v170_5_7_common_tags = merge(local.cis_v170_5_common_tags, {
    cis_section_id = "5.7"
  })
}

benchmark "cis_v170_5" {
  title       = "5 Policies (Deka GPU)"
  description = "This section contains recommendations for various Kubernetes policies which are important to the security of the environment, with enhanced CloudekaGuard support."
  children = [
    benchmark.cis_v170_5_1,
    benchmark.cis_v170_5_2,
    benchmark.cis_v170_5_3,
    benchmark.cis_v170_5_7
  ]

  tags = merge(local.cis_v170_5_common_tags, {
    type = "Benchmark"
  })
}

benchmark "cis_v170_5_1" {
  title         = "5.1 RBAC and Service Accounts (Deka GPU)"
  description   = "This section contains recommendations for various Kubernetes RBAC policies which can also govern the behavior of software resources, that Kubernetes identifies as service accounts."
  documentation = file("./cis_v170/docs/cis_v170_5_1.md")
  children = [
    control.cis_v170_5_1_3,
    control.cis_v170_5_1_6
  ]

  tags = merge(local.cis_v170_5_1_common_tags, {
    type = "Benchmark"
  })
}

control "cis_v170_5_1_3" {
  title         = "5.1.3 Minimize wildcard use in Roles and ClusterRoles"
  description   = "Kubernetes Roles and ClusterRoles provide access to resources based on sets of objects and actions that can be taken on those objects. It is possible to set either of these to be the wildcard \"*\" which matches all items. Use of wildcards is not optimal from a security perspective as it may allow for inadvertent access to be granted when new resources are added to the Kubernetes API either as CRDs or in later versions of the product."
  query         = query.role_with_wildcards_used
  documentation = file("./cis_v170/docs/cis_v170_5_1_3.md")

  tags = merge(local.cis_v170_5_1_common_tags, {
    cis_level   = "1"
    cis_item_id = "5.1.3"
    cis_type    = "manual"
    service     = "Kubernetes/Role"
  })
}

control "cis_v170_5_1_6" {
  title         = "5.1.6 Ensure that Service Account Tokens are only mounted where necessary"
  description   = "Service accounts tokens should not be mounted in pods except where the workload running in the pod explicitly needs to communicate with the API server."
  query         = query.pod_service_account_token_disabled
  documentation = file("./cis_v170/docs/cis_v170_5_1_6.md")

  tags = merge(local.cis_v170_5_1_common_tags, {
    cis_level   = "1"
    cis_item_id = "5.1.6"
    cis_type    = "manual"
    service     = "Kubernetes/Pod"
  })
}

benchmark "cis_v170_5_2" {
  title         = "5.2 Pod Security (Deka GPU)"
  description   = "This section contains recommendations for pod security policies and container security configurations to ensure proper isolation and security of workloads."
  documentation = file("./cis_v170/docs/cis_v170_5_2.md")
  children = [
    control.cis_v170_5_2_2,
    control.cis_v170_5_2_4,
    control.cis_v170_5_2_5,
    control.cis_v170_5_2_6,
    control.cis_v170_5_2_7,
    control.cis_v170_5_2_12
  ]

  tags = merge(local.cis_v170_5_2_common_tags, {
    type = "Benchmark"
  })
}

control "cis_v170_5_2_2" {
  title         = "5.2.2 Ensure containers run with a read-only root filesystem"
  description   = "Containers should always run with a read-only root filesystem. Using an immutable root filesystem and a verified boot mechanism prevents against attackers from owning the machine through permanent local changes. An immutable root filesystem can also prevent malicious binaries from writing to the host system."
  query         = query.pod_immutable_container_filesystem
  documentation = file("./cis_v170/docs/cis_v170_5_2_2.md")

  tags = merge(local.cis_v170_5_2_common_tags, {
    cis_level   = "2"
    cis_item_id = "5.2.2"
    cis_type    = "automated"
    service     = "Kubernetes/Pod"
  })
}

control "cis_v170_5_2_4" {
  title         = "5.2.4 Ensure containers have resource limits defined"
  description   = "Resource limits provide a way to constrain the amount of CPU, memory, and other resources that a container can use. This prevents resource exhaustion attacks and ensures fair resource allocation across all containers in the cluster."
  query         = query.pod_container_resource_limits_defined
  documentation = file("./cis_v170/docs/cis_v170_5_2_4.md")

  tags = merge(local.cis_v170_5_2_common_tags, {
    cis_level   = "2"
    cis_item_id = "5.2.4"
    cis_type    = "automated"
    service     = "Kubernetes/Pod"
  })
}

control "cis_v170_5_2_5" {
  title         = "5.2.5 Ensure containers do not run with host network access"
  description   = "Containers should not run in the host network of the node where the pod is deployed. When running on the host network, the pod can use the network namespace and network resources of the node. In this case, the pod can access loopback devices, listen to addresses, and monitor the traffic of other pods on the node."
  query         = query.pod_host_network_access_disabled
  documentation = file("./cis_v170/docs/cis_v170_5_2_5.md")

  tags = merge(local.cis_v170_5_2_common_tags, {
    cis_level   = "2"
    cis_item_id = "5.2.5"
    cis_type    = "automated"
    service     = "Kubernetes/Pod"
  })
}

control "cis_v170_5_2_6" {
  title         = "5.2.6 Ensure containers do not run with privileged access"
  description   = "Privileged containers have access to all Linux Kernel capabilities and devices. A container running with full privileges can do almost everything that the host can do. This flag exists to allow special use-cases, like manipulating the network stack and accessing devices. There should be at least one PodSecurityPolicy (PSP) defined which does not permit privileged containers."
  query         = query.pod_container_privilege_disabled
  documentation = file("./cis_v170/docs/cis_v170_5_2_6.md")

  tags = merge(local.cis_v170_5_2_common_tags, {
    cis_level   = "1"
    cis_item_id = "5.2.6"
    cis_type    = "automated"
    service     = "Kubernetes/Pod"
  })
}

control "cis_v170_5_2_7" {
  title         = "5.2.7 Ensure containers do not run as root user"
  description   = "Containers should not be deployed with root privileges. By default, many container services run as the privileged root user, and applications execute inside the container as root despite not requiring privileged execution. Preventing root execution by using non-root containers or a rootless container engine limits the impact of a container compromise."
  query         = query.pod_non_root_container
  documentation = file("./cis_v170/docs/cis_v170_5_2_7.md")

  tags = merge(local.cis_v170_5_2_common_tags, {
    cis_level   = "2"
    cis_item_id = "5.2.7"
    cis_type    = "automated"
    service     = "Kubernetes/Pod"
  })
}

control "cis_v170_5_2_12" {
  title         = "5.2.12 Ensure containers do not use hostPath volumes"
  description   = "Containers should not be able to access any specific paths of the host file system. There are many ways a container with unrestricted access to the host filesystem can escalate privileges, including reading data from other containers, and abusing the credentials of system services, such as Kubelet."
  query         = query.pod_volume_host_path
  documentation = file("./cis_v170/docs/cis_v170_5_2_12.md")

  tags = merge(local.cis_v170_5_2_common_tags, {
    cis_level   = "2"
    cis_item_id = "5.2.12"
    cis_type    = "automated"
    service     = "Kubernetes/Pod"
  })
}

benchmark "cis_v170_5_3" {
  title         = "5.3 Network Policies and CNI (Deka GPU)"
  description   = "This section contains recommendations for network policies and the Container Network Interface (CNI). It recommends implementing CloudekaGuard network policies ensuring that only authorized connections are allowed."
  documentation = file("./cis_v170/docs/cis_v170_5_3.md")
  children = [
    benchmark.cis_v170_5_3_2
  ]

  tags = merge(local.cis_v170_5_3_common_tags, {
    type = "Benchmark"
  })
}

benchmark "cis_v170_5_3_2" {
  title         = "5.3.2 Ensure that all Namespaces have CloudekaGuard Network Policies defined (Deka GPU)"
  description   = "Use CloudekaGuard policies to isolate traffic in your cluster network. CloudekaGuard is a custom resource that provides advanced network policy management capabilities using Cilium and KubeOVN."
  documentation = file("./cis_v170/docs/cis_v170_5_3_2.md")
  children = [
    control.cloudeka_guard_default_deny_egress,
    control.cloudeka_guard_default_deny_ingress,
    control.cloudeka_guard_default_dont_allow_egress,
    control.cloudeka_guard_default_dont_allow_ingress
  ]

  tags = merge(local.cis_v170_5_3_common_tags, {
    cis_level   = "2"
    cis_item_id = "5.3.2"
    cis_type    = "manual"
    type        = "Benchmark"
  })
}

benchmark "cis_v170_5_7" {
  title         = "5.7 General Policies (Deka GPU)"
  description   = "These policies relate to general cluster management topics, like namespace best practices and policies applied to pod objects in the cluster."
  documentation = file("./cis_v170/docs/cis_v170_5_7.md")
  children = [
    benchmark.cis_v170_5_7_2,
    benchmark.cis_v170_5_7_4
  ]

  tags = merge(local.cis_v170_5_7_common_tags, {
    type = "Benchmark"
  })
}

benchmark "cis_v170_5_7_2" {
  title         = "5.7.2 Ensure that the seccomp profile is set to docker/default in your Pod definitions"
  description   = "Enable `docker/default` seccomp profile in your pod definitions."
  documentation = file("./cis_v170/docs/cis_v170_5_7_2.md")
  children = [
    control.cronjob_default_seccomp_profile_enabled,
    control.daemonset_default_seccomp_profile_enabled,
    control.deployment_default_seccomp_profile_enabled,
    control.job_default_seccomp_profile_enabled,
    control.pod_default_seccomp_profile_enabled,
    control.replicaset_default_seccomp_profile_enabled,
    control.replication_controller_default_seccomp_profile_enabled,
    control.statefulset_default_seccomp_profile_enabled
  ]

  tags = merge(local.cis_v170_5_7_common_tags, {
    cis_level   = "2"
    cis_item_id = "5.7.2"
    cis_type    = "manual"
    type        = "Benchmark"
  })
}

benchmark "cis_v170_5_7_4" {
  title         = "5.7.4 Ensure that the default namespace is not used"
  description   = "The default namespace should not be used by Pods. Placing objects in this namespace makes application of RBAC and other controls more difficult."
  documentation = file("./cis_v170/docs/cis_v170_5_7_4.md")
  children = [
    control.pod_default_namespace_used
  ]

  tags = merge(local.cis_v170_5_7_common_tags, {
    cis_level   = "2"
    cis_item_id = "5.7.4"
    cis_type    = "manual"
    type        = "Benchmark"
  })
}
