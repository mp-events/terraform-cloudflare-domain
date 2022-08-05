locals {
  dmarc_order = ["v", "p", "sp", "pct", "ruf", "rua", "adkim", "aspf", "fo"]
  dmarc_record = var.dmarc_policy == null ? null : join(";",
    [for key in local.dmarc_order : "${key}=${var.dmarc_policy[key]}" if var.dmarc_policy[key] != null]
  )
}

resource "cloudflare_record" "dmarc" {
  count = var.dmarc_policy != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = "_dmarc.${local.fqdn}"
  value   = local.dmarc_record
  ttl     = var.ttl
}
