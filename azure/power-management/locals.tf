locals {
  tomorrow = formatdate(
    "YYYY-MM-DD", timeadd(timestamp(), "24h")
  )
}
