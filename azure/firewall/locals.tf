locals {
  fw_nat_rules = { for idx, rule in var.firewall_nat_rules : rule.name => {
    idx : idx,
    rule : rule,
    }
  }

  fw_network_rules = { for idx, rule in var.firewall_network_rules : rule.name => {
    idx : idx,
    rule : rule,
    }
  }

  fw_application_rules = { for idx, rule in var.firewall_application_rules : rule.name => {
    idx : idx,
    rule : rule,
    }
  }

  #   ports_premade = {
  #     "icmp" = {
  #       protocol = "Icmp"
  #     }
  #     "ssh" = {
  #       protocol = "Tcp"
  #       ports    = ["22"]
  #     }
  #     "rdp" = {
  #       protocol = "*"
  #       ports    = ["3389"]
  #     }
  #     "winrm" = {
  #       protocol = "Tcp"
  #       ports    = ["5985-5986"]
  #     }
  #     "dns" = {
  #       protocol = "*"
  #       ports    = ["53"]
  #     }
  #     "nfs" = {
  #       protocol = "*"
  #       ports    = ["2049"]
  #     }
  #     "ntp" = {
  #       protocol = "Udp"
  #       ports    = ["123"]
  #     }
  #     "http" = {
  #       protocol = "Tcp"
  #       ports    = ["80"]
  #     }
  #     "https" = {
  #       protocol = "Tcp"
  #       ports    = ["443"]
  #     }
  #     "mysql" = {
  #       protocol = "Tcp"
  #       ports    = ["3306"]
  #     }
  #     "mssql" = {
  #       protocol = "Tcp"
  #       ports    = ["1433"]
  #     }
  #     "deny" = {
  #       access = "Deny"
  #     }
  #   }
}
