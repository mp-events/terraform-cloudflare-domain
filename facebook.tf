locals {
  facebook = var.facebook
}

resource "cloudflare_record" "facebook_verification" {
  count = local.facebook.verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.fqdn
  value   = "facebook-domain-verification=${local.facebook.verification}"
  ttl     = var.ttl
}
