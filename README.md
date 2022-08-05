# Terraform CloudFlare Domain

This is a simple Terraform mudule that connects a CloudFlare-hosted domain to various service providers. The main goal of this module is to easily setup the required DNS records for E-Mail, verification, etc.

## Using the Module

You can use the module like so

```terraform
resource "cloudflare_zone" "example" {
  zone = "example.com"
}

module "example" {
	source = "github.com/mp-events/terraform-cloudflare-domain"
  
  zone_id = cloudflare_zone.example.id
  ttl     = 300 # optional
  
  microsoft {
    tenant  = "contoso"
    outlook = true
    # ...
  }
  
  google = {
    verification = "..."
  }
  
  # Additional Services
  
  dmarc_policy = ...
  spf_policy = {
    v    = "spf1"
    auto = ["microsoft"]
    all  = "fail"
  }
}
```

## Configuring E-Mail Security

This module supports a flexible configuration for `DMARC`, `SPF` and `DKIM` keys.

### DMARC configuration

You can configure DMARC using the `dmarc_policy` variable. It can be set to an object containing the following keys.

| Key     | Required | Description                                                  |
| ------- | -------- | ------------------------------------------------------------ |
| `v`     | Yes      | DKIM version. Should be set to `"DMARC1"`.                   |
| `pct`   | No       | Percentage of filtered mails.                                |
| `ruf`   | No       | Recipient of forensic reports.                               |
| `rua`   | No       | Recipient of aggregate reports.                              |
| `p`     | Yes      | DMARC policy value. `"none"`, `"quarantine"` or `"reject"`   |
| `sp`    | No       | Subdomain DMARC policy value. `"none"`, `"quarantine"` or `"reject"` |
| `adkim` | No       | DKIM mode. `"r"` or `"s"`                                    |
| `aspf`  | No       | SPF mode. `"r"` or `"s"`                                     |
| `fo`    | No       | Sets the forensic options.                                   |

### SPF Configuration

You can configure the domain’s SPF policy using the `spf_policy` variable. It can be set to an object containing the following keys:

| Key          | Required | Description                                                  |
| ------------ | -------- | ------------------------------------------------------------ |
| `v`          | Yes      | SPF version. Should be set to `"spf1"`                       |
| `directives` | No       | A list of SPF directives that are included verbatim.         |
| `redirect`   | No       | A SPF redirect policy (excluding the `redirect=` prefx).     |
| `exp`        | No       | The `exp` value of the SPF record. Note that the module currently does not handle exlanation values. You have to create the referenced explanation record yourself. |
| `all`        | No       | One of `"pass"`, `"fail"`, `"softfail"`, `"neutral"` determining how emails should be treated that do not conform to the SPF policy. |
| `auto`       | No       | A list of service names. For some service names the module contains known SPF `include:` policies. Using the `auto` mechanism you can use these known values instead of writing your own `directives`. For example including `"microsoft"` in `auto` will add `include:spf.protection.outlook.com` to the generated SPF policy. |

## Custom DKIM Keys

You can include DKIM keys for a domain using the `dkim_keys` map. Keys are domain names in the `_domainkey` namespace. Values are DKIM values. The map supports two formats:

- Raw DKIM keys: This is the usual case where you receive a DKIM key from a provider and want to add it to the domain. Paste the value as a value here.
- CNAME references. If the value looks like a domain name instead of a DKIM key the module will instead create a CNAME for the specified key. This is used by some providers such as Exchange Online.

Note that many service providers already implement their own DKIM records so in many cases you don’t have to set this variable manually.

The DKIM keys are somewhat special as the do support subdomains without setting the `domain` variable. Consider the following configuration:

```terraform
resource "cloudflare_zone" "example" {
  zone = "example.com"
}

module "example" {
	source = "github.com/mp-events/terraform-cloudflare-domain"
  
  zone_id = cloudflare_zone.example.id
  ttl 		= 300
  
  dkim_keys = {
    key1     = "k=rsa; t=s; p=MIG..."
    key2.sub = "another.host"
  }
}
```

This will create two records:

```
key1._domainkey.example.com.     300 IN TXT   "k=rsa; t=s; p=MIG..."
key2._domainkey.sub.example.com. 300 IN CNAME another.host.
```

## Service Providers

### Apple

Connect the domain to Apple Business Manager by setting the `apple` variable to an object containing the following keys:

| Key            | Required | Description                                                  |
| -------------- | -------- | ------------------------------------------------------------ |
| `verification` | No       | The Apple verification code excluding the `"apple-domain-verification="` prefix. |

### Atlassian Cloud

Connect the domain to Atlassian Cloud by setting the `atlassian` variable to an object containing the following keys:

| Key                  | Required | Description                                                  |
| -------------------- | -------- | ------------------------------------------------------------ |
| `verification`       | No       | Atlassian Domain Verification. Should not include the `"atlassian-domain-verification="` prefix. |
| `email_verification` | No       | The E-Mail verification string. Should not include the `"atlassian-sending-domain-verification="` prefix. If specified a `CNAME` record for bounces will be added as well. |

### Facebook

Connect the domain to Facebook by setting the `facebook` variable to an object containing the following keys:

| Key            | Required | Description                                                  |
| -------------- | -------- | ------------------------------------------------------------ |
| `verification` | No       | The Facebook verification code excluding the `"facebook-domain-verification="` prefix. |

### Google

Connect the domain to Google by setting the `google` variable to an object containing the following keys:

| Key            | Required | Description                                                  |
| -------------- | -------- | ------------------------------------------------------------ |
| `verification` | No       | The Google Site verification code (excluding the `"google-site-verification="` prefix). |
| `gmail`        | No       | If `true` add GMail `MX` records.                            |

### Mailcheap

Connect the domain to Mailcheap by setting the `mailcheap` variable to an object containing the following keys:

| Key            | Required                  | Description                              |
| -------------- | ------------------------- | ---------------------------------------- |
| `verification` | No                        | The verification string for the domain.  |
| `host`         | Only if `email` is `true` | The hostname of your Mailcheap solution. |
| `email`        | No                        | If `true` add Mailcheap `MX` records.    |

### Mailgun

Connect the domain to Mailgun by setting the `mailgun` variable to an object containing the following keys. If the `mailgun` object is set the module will automatically register the domain with Mailgun. You should not manually add the domain to Mailgun.

| Key             | Required | Description                                                  |
| --------------- | -------- | ------------------------------------------------------------ |
| `region`        | No       | The Mailgun region. Defaults to `"us"` but may be set to `"eu"`. |
| `dkim`          | No       | Automatically add the Mailgun DKIM keys. Defaults to `true`. |
| `spf`           | No       | `"auto"` or `"custom"`. If set to `"auto"` (default) add the Mailgun SPF record to the domain. If `"custom"` use the `spf_policy` variable. You should not set a `spf_policy` when setting this to `"auto"`. |
| `tracking`      | No       | Add the tracking records to the domain. Defaults to `true`.  |
| `receiving`     | No       | Also add receiving `MX` records. Defaults to `true`.         |
| `spam_action`   | No       | Configure how Mailgun should handle Spam. Defaults to `"disabled"` |
| `dkim_key_size` | No       | Specifies the size of the DKIM key that should be generated. Defaults to `2048`. |

### Microsoft

Connect the domain to Microsoft by setting the `microsoft` variable to an object containing the following keys:

| Key            | Required                           | Description                                                  |
| -------------- | ---------------------------------- | ------------------------------------------------------------ |
| `verification` | No                                 | A verification string for the domain.                        |
| `tenant`       | Only if `dkim` is `true`           | The name of your Microsoft tenant (the part before `.onmicrosoft.com`). |
| `domain`       | If `outlook`  or `dkim` are `true` | The ID of the domain. In simple cases this can be inferred automatically (basically by removing dashes). However in some cases this domain cannot be guessed. |
| `outlook`      | No                                 | If set to `true` the `MX` records for outlook will be created |
| `autodiscover` | No                                 | If set to `true` the Outlook Autodiscover record will be created. |
| `skype`        | No                                 | If set to `true` the SIP records for Skype will be created.  |
| `intune`       | No                                 | If set to `true` the MDM registration records for Intune will be created. |
| `dkim`         | No                                 | If set to `true` the Outlook DKIM keys will be added.        |

### MXRoute

Connect the domain to MXRoute by setting the `mxroute` variable to an object containing the following keys:

| Key      | Required                   | Description                                                 |
| -------- | -------------------------- | ----------------------------------------------------------- |
| `server` | Only if `email` is `true`. | The ID of your MXRoute server (excluding `".mxlogin.com"`). |
| `email`  | No                         | If `true` add the MXRoute `MX` records.                     |

### OVH

Connect the domain to OVH by setting the `ovh` variable to an object containing the following keys:

| Key            | Required | Description                                                  |
| -------------- | -------- | ------------------------------------------------------------ |
| `verification` | No       | The name of the subdomain used for verification.             |
| `server`       | No       | Specify the server of your mail solution. This will add the appropriate autodiscover record. |
| `email`        | No       | If set to `true` will add OVH `MX` records.                  |

## Configuring a subdomain

By default this module is used to configure the apex of a zone. However in certain cases you might only want to configure a subdomain with certain services. To do so you can use the `domain` variable. The variable can be set to the name of a subdomain or the fully qualified domain name that you want to configure.

```terraform
resource "cloudflare_zone" "example" {
  zone = "example.com"
}

module "example" {
	source = "github.com/mp-events/terraform-cloudflare-domain"
  
  zone_id = cloudflare_zone.example.id
  # We are configuring sub.exampe.com
  domain = "sub"
  # This is equivalent
  #domain = "sub.example.com"
}
```

## Configuring Certificate Authorities

You can create `CAA` records by setting the `certificate_authorities` variable to a list of objects containing the following values:

| Key     | Required | Description                       |
| ------- | -------- | --------------------------------- |
| `flags` | Yes      | Sets the flags of the CAA record. |
| `tag`   | Yes      | Sets the tag of the CAA record.   |
| `value` | Yes      | Sets the value of the CAA record. |

## Configuring the TTL of records

You can set the TTL for created records using the `ttl` variable.
