query "cloudeka_guard_default_dont_allow_ingress" {
  sql = <<-EOQ
    with cloudeka_guard_allow_all_analysis as (
      select
        namespace,
        name,
        uid,
        labels,
        annotations,
        ingress,
        -- Check if this policy allows all ingress traffic (CloudekaGuard semantics)
        case
          when ingress is null then true  -- No ingress field = allow all (no restrictions)
          when jsonb_array_length(ingress) = 0 then true  -- Empty array = allow all
          when ingress = '[]'::jsonb then true  -- Explicitly empty = allow all
          when ingress = '[{}]'::jsonb then false  -- Deny-all pattern = good (not allowing all)
          else (
            -- Check if any rule allows overly broad traffic
            select bool_or(
              -- Rule with no specific restrictions = overly permissive
              (not (rule ? 'fromEndpoints') and 
               not (rule ? 'fromCIDR') and 
               not (rule ? 'fromCIDRSet') and
               rule != '{}'::jsonb)  -- Exclude the deny-all pattern
            )
            from jsonb_array_elements(ingress) as rule
          )
        end as allows_all_ingress
      from
        kubernetes_cloudeka_guard
    )
    select
      uid as resource,
      case
        when allows_all_ingress then 'alarm'
        else 'ok'
      end as status,
      case
        when allows_all_ingress then name || ' allows all ingress traffic'
        else name || ' does not allow all ingress traffic'
      end as reason,
      name as cloudeka_guard_name,
      namespace
    from
      cloudeka_guard_allow_all_analysis;
  EOQ
}

query "cloudeka_guard_default_dont_allow_egress" {
  sql = <<-EOQ
    with cloudeka_guard_allow_all_analysis as (
      select
        namespace,
        name,
        uid,
        labels,
        annotations,
        egress,
        -- Check if this policy allows all egress traffic (CloudekaGuard semantics)
        case
          when egress is null then true  -- No egress field = allow all (no restrictions)
          when jsonb_array_length(egress) = 0 then true  -- Empty array = allow all
          when egress = '[]'::jsonb then true  -- Explicitly empty = allow all
          when egress = '[{}]'::jsonb then false  -- Deny-all pattern = good (not allowing all)
          else (
            -- Check if any rule allows overly broad traffic
            select bool_or(
              -- Rule with no specific restrictions = overly permissive
              (not (rule ? 'toEndpoints') and 
               not (rule ? 'toCIDR') and 
               not (rule ? 'toCIDRSet') and
               rule != '{}'::jsonb)  -- Exclude the deny-all pattern
            )
            from jsonb_array_elements(egress) as rule
          )
        end as allows_all_egress
      from
        kubernetes_cloudeka_guard
    )
    select
      uid as resource,
      case
        when allows_all_egress then 'alarm'
        else 'ok'
      end as status,
      case
        when allows_all_egress then name || ' allows all egress traffic'
        else name || ' does not allow all egress traffic'
      end as reason,
      name as cloudeka_guard_name,
      namespace
    from
      cloudeka_guard_allow_all_analysis;
  EOQ
}

query "cloudeka_guard_default_deny_ingress" {
  sql = <<-EOQ
    with default_deny_ingress_count as (
      select
        ns.uid,
        ns.name as namespace,
        count(guard.*) as num_guards,
        -- Count CloudekaGuards that deny all ingress traffic
        -- In CloudekaGuard: ingress with empty object [{}] = deny all
        count(*) filter (
          where (
            -- Global endpoint selector (selects all/most pods in namespace)
            guard.endpoint_selector ? 'matchLabels' and 
            (guard.endpoint_selector->'matchLabels' ? 'namespace' or
             guard.endpoint_selector->'matchLabels' ? 'any:namespace')
          )
          and (
            -- CloudekaGuard deny-all pattern: ingress array with single empty object
            guard.ingress = '[{}]'::jsonb
          )
        ) as num_default_deny_ingress
      from kubernetes_namespace as ns
      left join kubernetes_cloudeka_guard as guard on guard.namespace = ns.name
      group by
        ns.name,
        ns.uid
    )
    select
      uid as resource,
      case
        when num_default_deny_ingress > 0 then 'ok'
        else 'alarm'
      end as status,
      namespace || ' has ' || num_default_deny_ingress || ' default deny ingress CloudekaGuard policies.' as reason,
      namespace
    from
      default_deny_ingress_count;
  EOQ
}

query "cloudeka_guard_default_deny_egress" {
  sql = <<-EOQ
    with default_deny_egress_count as (
      select
        ns.uid,
        ns.name as namespace,
        count(guard.*) as num_guards,
        -- Count CloudekaGuards that deny all egress traffic
        -- In CloudekaGuard: egress with empty object [{}] = deny all
        count(*) filter (
          where (
            -- Global endpoint selector (selects all/most pods in namespace)
            guard.endpoint_selector ? 'matchLabels' and 
            (guard.endpoint_selector->'matchLabels' ? 'namespace' or
             guard.endpoint_selector->'matchLabels' ? 'any:namespace')
          )
          and (
            -- CloudekaGuard deny-all pattern: egress array with single empty object
            guard.egress = '[{}]'::jsonb
          )
        ) as num_default_deny_egress
      from kubernetes_namespace as ns
      left join kubernetes_cloudeka_guard as guard on guard.namespace = ns.name
      group by
        ns.name,
        ns.uid
    )
    select
      uid as resource,
      case
        when num_default_deny_egress > 0 then 'ok'
        else 'alarm'
      end as status,
      namespace || ' has ' || num_default_deny_egress || ' default deny egress CloudekaGuard policies.' as reason,
      namespace
    from
      default_deny_egress_count;
  EOQ
} 