locals {
  fqdn = var.domain == null ? data.cloudflare_zone.zone.name : (length(trimsuffix(var.domain, data.cloudflare_zone.zone.name)) == length(var.domain) ? "${var.domain}.${data.cloudflare_zone.zone.name}" : var.domain)
}

data "cloudflare_zone" "zone" {
  zone_id = var.zone_id
}

resource "cloudflare_record" "caa" {
  count = length(var.certificate_authorities)

  zone_id = var.zone_id
  type    = "CAA"
  name    = local.fqdn
  ttl     = var.ttl

  data {
    flags = var.certificate_authorities[count.index].flags
    tag   = var.certificate_authorities[count.index].tag
    value = var.certificate_authorities[count.index].value
  }
}
