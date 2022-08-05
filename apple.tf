locals {
  apple = defaults(var.apple, {})
}

resource "cloudflare_record" "apple_domain_verification" {
  count = local.apple.verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.fqdn
  value   = "apple-domain-verification=${local.apple.verification}"
  ttl     = var.ttl
}
