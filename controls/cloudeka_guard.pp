locals {
  cloudeka_guard_common_tags = merge(local.kubernetes_compliance_common_tags, {
    service = "Kubernetes/CloudekaGuard"
  })
}

control "cloudeka_guard_default_deny_egress" {
  title       = "Namespaces should have a default CloudekaGuard policy to deny all egress traffic"
  description = "Administrators should use a default CloudekaGuard policy selecting all Pods to deny all egress traffic and ensure any unselected Pods are isolated. Additional policies could then relax these restrictions for permissible connections."
  query       = query.cloudeka_guard_default_deny_egress

  tags = merge(local.cloudeka_guard_common_tags, {
    cis         = "true"
    nsa_cisa_v1 = "true"
  })
}

control "cloudeka_guard_default_deny_ingress" {
  title       = "Namespaces should have a default CloudekaGuard policy to deny all ingress traffic"
  description = "Administrators should use a default CloudekaGuard policy selecting all Pods to deny all ingress traffic and ensure any unselected Pods are isolated. Additional policies could then relax these restrictions for permissible connections."
  query       = query.cloudeka_guard_default_deny_ingress

  tags = merge(local.cloudeka_guard_common_tags, {
    cis         = "true"
    nsa_cisa_v1 = "true"
  })
}

control "cloudeka_guard_default_dont_allow_egress" {
  title       = "CloudekaGuard policies should not have a default policy to allow all egress traffic"
  description = "Administrators should use a default CloudekaGuard policy selecting all Pods to deny all ingress and egress traffic and ensure any unselected Pods are isolated. An 'allow all' policy would override this default and should not be used. Instead, use specific policies to relax these restrictions only for permissible connections."
  query       = query.cloudeka_guard_default_dont_allow_egress

  tags = merge(local.cloudeka_guard_common_tags, {
    cis         = "true"
    nsa_cisa_v1 = "true"
  })
}

control "cloudeka_guard_default_dont_allow_ingress" {
  title       = "CloudekaGuard policies should not have a default policy to allow all ingress traffic"
  description = "Administrators should use a default CloudekaGuard policy selecting all Pods to deny all ingress and egress traffic and ensure any unselected Pods are isolated. An 'allow all' policy would override this default and should not be used. Instead, use specific policies to relax these restrictions only for permissible connections."
  query       = query.cloudeka_guard_default_dont_allow_ingress

  tags = merge(local.cloudeka_guard_common_tags, {
    cis         = "true"
    nsa_cisa_v1 = "true"
  })
} 