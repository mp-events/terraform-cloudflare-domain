locals {
  known_spf = {
    microsoft  = "include:spf.protection.outlook.com"
    ovh        = "include:mx.ovh.com"
    mailjet    = "include:spf.mailjet.com"
    mailgun-eu = "include:eu.mailgun.org"
    atlassian  = "include:_spf.atlassian.net"
    mxroute    = "include:mxlogin.com"
    mailcheap = join(" ", concat(
      var.mailcheap.host != null ? ["a:${var.mailcheap.host}"] : [],
      ["a:relay.mymailcheap.com"]
    ))
  }
  spf_all_policies = {
    pass     = "+all",
    fail     = "-all"
    softfail = "~all"
    neutral  = "?all"
  }
  spf_record = var.spf_policy == null ? "" : join(" ", concat(
    ["v=${var.spf_policy.v}"],
    var.spf_policy.exp != null ? ["exp=${var.spf_policy.exp}"] : [],
    [for service in coalesce(var.spf_policy.auto, []) : local.known_spf[service]],
    var.spf_policy.directives != null ? var.spf_policy.directives : [],
    var.spf_policy.redirect != null ? ["redirect=${var.spf_policy.redirect}"] : [],
    var.spf_policy.all != null ? [local.spf_all_policies[var.spf_policy.all]] : []
  ))
}

resource "cloudflare_record" "spf" {
  count = var.spf_policy != null ? 1 : 0

  zone_id = var.zone_id
  type    = "TXT"
  name    = local.fqdn
  value   = local.spf_record
  ttl     = var.ttl
}
