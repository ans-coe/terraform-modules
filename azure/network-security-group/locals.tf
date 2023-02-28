locals {
  rules_premade = {
    "icmp" = {
      protocol = "Icmp"
    }
    "ssh" = {
      protocol = "Tcp"
      ports    = ["22"]
    }
    "rdp" = {
      protocol = "*"
      ports    = ["3389"]
    }
    "winrm" = {
      protocol = "Tcp"
      ports    = ["5985-5986"]
    }
    "dns" = {
      protocol = "*"
      ports    = ["53"]
    }
    "nfs" = {
      protocol = "*"
      ports    = ["2049"]
    }
    "ntp" = {
      protocol = "Udp"
      ports    = ["123"]
    }
    "http" = {
      protocol = "Tcp"
      ports    = ["80"]
    }
    "https" = {
      protocol = "Tcp"
      ports    = ["443"]
    }
    "mysql" = {
      protocol = "Tcp"
      ports    = ["3306"]
    }
    "mssql" = {
      protocol = "Tcp"
      ports    = ["1433"]
    }
    "deny" = {
      access = "Deny"
    }
  }
  rules_inbound = merge(
    { for r in var.rules_inbound : r.name => merge(r, local.rules_premade[r.rule]) if r.rule != null },
    { for r in var.rules_inbound : r.name => r if r.rule == null }
  )
  rules_outbound = merge(
    { for r in var.rules_outbound : r.name => merge(r, local.rules_premade[r.rule]) if r.rule != null },
    { for r in var.rules_outbound : r.name => r if r.rule == null }
  )
}
