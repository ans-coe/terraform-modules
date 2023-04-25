locals {
default_frontend_ports = {
  "Http"  = 80
  "Https" = 443
}
enable_autoscaling = var.sku.max_capacity > var.sku.capacity
}