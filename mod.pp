mod "kubernetes_compliance" {
  # Hub metadata
  title         = "Deka GPU CIS"
  description   = "CIS v1.7.0 Kubernetes compliance with CloudekaGuard support for advanced network policy management using Cilium and KubeOVN."
  color         = "#0089D6"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/kubernetes-compliance.svg"
  categories    = ["kubernetes", "compliance", "security", "cis"]

  opengraph {
    title       = "Deka GPU CIS - Kubernetes Compliance"
    description = "CIS v1.7.0 Kubernetes compliance with CloudekaGuard support for advanced network policy management using Cilium and KubeOVN."
    image       = "/images/mods/turbot/kubernetes-compliance-social-graphic.png"
  }
  requires {
    plugin "kubernetes" {
      min_version = "0.23.0"
    }
  }
}
