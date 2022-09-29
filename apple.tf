resource "cloudflare_record" "apple_domain_verification" {
  count = var.apple.verification != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.fqdn
  value   = "apple-domain-verification=${var.apple.verification}"
  ttl     = var.ttl
}
