locals {
  mailcheap = defaults(var.mailcheap, {
    email = false
  })
}

resource "cloudflare_record" "mailcheap_verification" {
  count = local.mailcheap.verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.fqdn
  value   = local.mailcheap.verification
  ttl     = var.ttl
}

resource "cloudflare_record" "mailcheap_mx" {
  for_each = local.mailcheap.email ? {
    (local.mailcheap.host) = 1
    "alt1.mymailcheap.com" = 5
    "alt2.mymailcheap.com" = 10
  } : {}

  zone_id  = var.zone_id
  type     = "MX"
  name     = local.fqdn
  value    = each.key
  priority = each.value
  ttl      = var.ttl
}
