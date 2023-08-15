locals {
  whitelist = try(length(var.whitelist) == 0, false) ? ["Internet"] : var.whitelist
}