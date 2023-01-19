locals {
  managed_subscriptions = concat(
    [data.azurerm_subscription.current.subscription_id],
    var.managed_subscription_ids
  )

  managed_scopes = [
    for s in local.managed_subscriptions :
    "/subscriptions/${s}"
  ]

  tomorrow = formatdate(
    "YYYY-MM-DD", timeadd(timestamp(), "24h")
  )
}
