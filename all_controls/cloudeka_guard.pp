locals {
  all_controls_cloudeka_guard_common_tags = merge(local.all_controls_common_tags, {
    service = "Kubernetes/CloudekaGuard"
  })
}

benchmark "all_controls_cloudeka_guard" {
  title       = "CloudekaGuard"
  description = "This section contains recommendations for configuring CloudekaGuard CRD resources."
  children = [
    control.cloudeka_guard_default_deny_egress,
    control.cloudeka_guard_default_deny_ingress,
    control.cloudeka_guard_default_dont_allow_egress,
    control.cloudeka_guard_default_dont_allow_ingress
  ]

  tags = merge(local.all_controls_cloudeka_guard_common_tags, {
    type = "Benchmark"
  })
} 