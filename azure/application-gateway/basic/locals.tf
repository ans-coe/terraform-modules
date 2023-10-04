locals {
  enable_autoscaling    = var.autoscale_configuration != null
  public_frontend_name  = "public"
  private_frontend_name = "private"
  enable_waf            = length(regexall("WAF", var.sku.name)) > 0
  default_frontend_ports = {
    "Http"  = 80
    "Https" = 443
  }
  backends = merge(
    var.basic_backends,
    var.redirect_backends
  )
}
