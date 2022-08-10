terraform {
  required_version = ">= 1.1.4"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.21.0"
    }
    mailgun = {
      source  = "wgebis/mailgun"
      version = "~> 0.7.2"
    }
  }

  experiments = [module_variable_optional_attrs]
}
