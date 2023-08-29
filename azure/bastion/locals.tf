######### 
# Locals
#########

locals {
  whitelist = length(var.whitelist) >= 1 ? var.whitelist : ["Internet"]
}