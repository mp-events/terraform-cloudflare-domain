locals {
  ovh = defaults(var.ovh, {
    email = false
  })
}

resource "cloudflare_record" "ovh_validation" {
  count = local.ovh.verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "CNAME"
  name    = "${local.ovh.verification}.${local.fqdn}"
  value   = "ovh.com"
  ttl     = var.ttl
}

resource "cloudflare_record" "ovh_autodiscover" {
  count = local.ovh.server != null ? 1 : 0

  zone_id = var.zone_id
  type    = "SRV"
  name    = "_autodiscover._tcp.${local.fqdn}"
  ttl     = var.ttl

  data {
    service  = "_autodiscover"
    proto    = "_tcp"
    name     = local.fqdn
    priority = 0
    weight   = 0
    port     = 443
    target   = local.ovh.server
  }
}

resource "cloudflare_record" "ovh_mx" {
  for_each = local.ovh.email ? {
    "mx3.mail.ovh.net" = 100
    "mx2.mail.ovh.net" = 50
    "mx1.mail.ovh.net" = 5
    "mx0.mail.ovh.net" = 1
  } : {}

  zone_id  = var.zone_id
  type     = "MX"
  name     = local.fqdn
  value    = each.key
  priority = each.value
  ttl      = var.ttl
}
