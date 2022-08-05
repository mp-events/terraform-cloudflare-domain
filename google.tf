locals {
  google = defaults(var.google, {
    gmail = false
  })
}

resource "cloudflare_record" "google_site_verification" {
  count = local.google.verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.fqdn
  value   = "google-site-verification=${local.google.verification}"
  ttl     = var.ttl
}

resource "cloudflare_record" "gmail" {
  for_each = local.google.gmail ? {
    "aspmx.l.google.com"      = 1
    "alt1.aspmx.l.google.com" = 5
    "alt2.aspmx.l.google.com" = 5
    "alt3.aspmx.l.google.com" = 10
    "alt4.aspmx.l.google.com" = 10
  } : {}

  zone_id  = var.zone_id
  type     = "MX"
  name     = local.fqdn
  value    = each.key
  priority = each.value
  ttl      = var.ttl
}
