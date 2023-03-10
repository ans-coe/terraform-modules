locals {
  default_app_settings = {

  }
  app_settings = merge(local.default_app_settings, var.app_settings)

  allowed_subnet_ids = [
    for id in var.allowed_subnet_ids
    : {
      name     = "ip_restriction_subnet_id_${join("", [1, index(var.allowed_subnet_ids, id)])}"
      priority = join("", [1, index(var.allowed_subnet_ids, id)])
      action   = "Allow"

      ip_address                = null
      virtual_network_subnet_id = id
      service_tag               = null

      headers = null
    }
  ]
  allowed_service_tags = [
    for st in var.allowed_service_tags
    : {
      name     = "ip_restriction_service_tag_${join("", [2, index(var.allowed_service_tags, st)])}"
      priority = join("", [2, index(var.allowed_service_tags, st)])
      action   = "Allow"

      ip_address                = null
      virtual_network_subnet_id = null
      service_tag               = st

      headers = null
    }
  ]
  allowed_ips = [
    for ip in var.allowed_ips
    : {
      name     = "ip_restriction_cidr_${join("", [3, index(var.allowed_ips, ip)])}"
      priority = join("", [3, index(var.allowed_ips, ip)])
      action   = "Allow"

      ip_address                = ip
      virtual_network_subnet_id = null
      service_tag               = null

      headers = null
    }
  ]
  allowed_frontdoor_ids = length(var.allowed_frontdoor_ids) == 0 ? [] : [
    {
      name     = "ip_restriction_frontdoor_5"
      priority = 5
      action   = "Allow"

      ip_address                = null
      virtual_network_subnet_id = null
      service_tag               = "AzureFrontDoor.Backend"

      headers = [{
        x_azure_fdid      = var.allowed_frontdoor_ids
        x_fd_health_probe = null
        x_forwarded_for   = null
        x_forwarded_host  = null
      }]
    }
  ]

  access_rules = concat(
    local.allowed_subnet_ids, local.allowed_service_tags,
    local.allowed_ips, local.allowed_frontdoor_ids
  )

  allowed_scm_subnet_ids = [
    for id in var.allowed_scm_subnet_ids
    : {
      name     = "ip_restriction_subnet_id_${join("", [1, index(var.allowed_scm_subnet_ids, id)])}"
      priority = join("", [1, index(var.allowed_scm_subnet_ids, id)])
      action   = "Allow"

      ip_address                = null
      virtual_network_subnet_id = id
      service_tag               = null

      headers = null
    }
  ]
  allowed_scm_service_tags = [
    for st in var.allowed_scm_service_tags
    : {
      name     = "ip_restriction_service_tag_${join("", [2, index(var.allowed_scm_service_tags, st)])}"
      priority = join("", [2, index(var.allowed_scm_service_tags, st)])
      action   = "Allow"

      ip_address                = null
      virtual_network_subnet_id = null
      service_tag               = st

      headers = null
    }
  ]
  allowed_scm_ips = [
    for ip in var.allowed_scm_ips
    : {
      name     = "scm_ip_restriction_cidr_${join("", [3, index(var.allowed_scm_ips, ip)])}"
      priority = join("", [3, index(var.allowed_scm_ips, ip)])
      action   = "Allow"

      ip_address                = ip
      virtual_network_subnet_id = null
      service_tag               = null

      headers = null
    }
  ]

  scm_access_rules = concat(
    local.allowed_scm_subnet_ids, local.allowed_scm_service_tags,
    local.allowed_scm_ips
  )
}
