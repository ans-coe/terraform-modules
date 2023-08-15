locals {
  default_resources = { for v in jsondecode(file("${path.module}/resourceDefinition.json")) : v.name => v }
  resource_list     = keys(merge(local.default_resources, var.resource_override))

  resource_properties = {
    for v in local.resource_list
    : v => {
      dashes = lookup(try(var.resource_override[v], {}), "dashes", lookup(local.default_resources[v], "dashes", true))
      regex  = lookup(try(var.resource_override[v], {}), "regex", lookup(local.default_resources[v], "regex", ".*"))
      scope  = lookup(try(var.resource_override[v], {}), "scope", lookup(local.default_resources[v], "scope", "global"))
      slug   = lookup(try(var.resource_override[v], {}), "slug", lookup(local.default_resources[v], "slug", ""))

      length = {
        max = lookup(try(lookup(var.resource_override[v],"length",{}), {}), "max", lookup(local.default_resources[v].length, "max", 0))
        min = lookup(try(lookup(var.resource_override[v],"length",{}), {}), "min", lookup(local.default_resources[v].length, "min", 100))
      }
      instance_numbering = lookup(try(var.resource_override[v], {}), "instance_numbering", lookup(local.default_resources[v], "instance_numbering", true))
    }
  }

  convention_definitions = {
    region      = "R"
    workload    = "W"
    department  = "D"
    environment = "E"
    type        = "T"
    instance    = "I"
    custom1     = "C1"
    custom2     = "C2"
    custom3     = "C3"
    custom4     = "C4"
    custom5     = "C5"
  }

  string_positions = [
    for i, c in transpose({
      for k, v in local.convention_definitions
      : k => try([index(var.convention, v)], [])
    }) : one(c)
  ]
  ## This should output an ordered list eg ["type","custom1"] - the ordering matters

  lookup = {
    for k, v in local.resource_properties
    : k => {
      type        = v.slug
      environment = var.environment
      region      = var.region
      workload    = var.workload
      department  = var.department
      custom1     = var.custom1
      custom2     = var.custom2
      custom3     = var.custom3
      custom4     = var.custom4
      custom5     = var.custom5
    }
  }

  az = {
    for k, v in local.resource_properties
    : k => [for n in range(1, var.max_instances) : {
      name = substr(join(v.dashes ? var.delimiter : "", compact([
        for i in local.string_positions
        : i != "instance" ? lookup(local.lookup[k], i) : (v.instance_numbering ? format("%0${var.instance_number_length}d", n) : "")
      ])), 0, v.length.max),
      length_min = v.length.min,
      length_max = v.length.max,
      dashes     = v.dashes,
      regex      = v.regex,
      scope      = v.scope,
      slug        = v.slug
    }]
  }
}


