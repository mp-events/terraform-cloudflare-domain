terraform {
  required_version = ">= 1.3.6"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 3.30.0"
    }
    mailgun = {
      source  = "wgebis/mailgun"
      version = ">= 0.7.4"
    }
  }
}
