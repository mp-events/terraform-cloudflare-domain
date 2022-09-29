terraform {
  required_version = ">= 1.3.1"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 3.20.0"
    }
    mailgun = {
      source  = "wgebis/mailgun"
      version = ">= 0.7.2"
    }
  }
}
