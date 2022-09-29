# ---------------------------------------------------------------------------------------------------------------------
# CLOUDFLARE SETTINGS
# Settings affecting the connection/zone in CloudFlare.
# ---------------------------------------------------------------------------------------------------------------------
variable "zone_id" {
  type        = string
  description = "The CloudFlare Zone ID corresponding to the domain that should be modified."
}

variable "domain" {
  type        = string
  default     = null
  description = "The fully qualified name of the domain to modify. Defaults to root zone name."
}

variable "ttl" {
  type        = number
  default     = null
  description = "The TTL used for created DNS records."
}

# ---------------------------------------------------------------------------------------------------------------------
# COMMON SETTINGS
# Settings for unique records.
# ---------------------------------------------------------------------------------------------------------------------
variable "dmarc_policy" {
  type = object({
    v     = string
    pct   = optional(number)
    ruf   = optional(string)
    rua   = optional(string)
    p     = string
    sp    = optional(string)
    adkim = optional(string)
    aspf  = optional(string)
    fo    = optional(string)
  })
  default     = null
  description = "The value of the DMARC TXT entry."
}

variable "spf_policy" {
  type = object({
    v          = string
    directives = optional(list(string))
    redirect   = optional(string)
    exp        = optional(string)
    all        = optional(string)
    # Identifiers for services for which to include SPF records automatically.
    auto = optional(list(string))
  })
  default     = null
  description = "Settings for the SPF policy."
}

variable "dkim_keys" {
  type        = map(string)
  default     = {}
  description = "A map of DKIM keys where the keys are the names of the respective keys."
}

variable "certificate_authorities" {
  type = list(object({
    flags = number
    tag   = string
    value = string
  }))
  default     = []
  description = "A list of certificate authorities to be configured as CAA records."
}

# ---------------------------------------------------------------------------------------------------------------------
# SERVICE PROVIDERS
# Configure the connection to different service providers.
# ---------------------------------------------------------------------------------------------------------------------
variable "microsoft" {
  type = object({
    verification = optional(string)
    tenant       = optional(string)
    domain       = optional(string)
    outlook      = optional(bool, false)
    autodiscover = optional(bool, false)
    skype        = optional(bool, false)
    intune       = optional(bool, false)
    dkim         = optional(bool, false)
  })
  default     = {}
  description = "Configures options to connect the domain to Microsoft."
}

variable "mailgun" {
  type = object({
    region = optional(string, "us")
    dkim   = optional(bool, true)
    spf    = optional(string, "auto") # Either "auto" or "custom". "custom" uses the module's SPF record. If "auto" you must not not
    # specify a spf_policy.
    tracking      = optional(bool, true)
    receiving     = optional(bool, true)
    spam_action   = optional(string, "disabled")
    dkim_key_size = optional(number, 2048)
  })
  default     = null
  description = "Configures options to connect the domain to Mailgun. Note that SPF and DKIM are required to verify the domain."
}

variable "atlassian" {
  type = object({
    verification       = optional(string)
    email_verification = optional(string)
  })
  default     = {}
  description = "Configure options to connect the domain to Atlassian."
}

variable "ovh" {
  type = object({
    verification = optional(string)
    server       = optional(string)
    email        = optional(bool, false)
  })
  default     = {}
  description = "Configure options to connect the domain to OVH."
}

variable "mailcheap" {
  type = object({
    verification = optional(string)
    host         = optional(string)
    email        = optional(bool, false)
  })
  default     = {}
  description = "Configure options to connect the domain to Mailcheap."
}

variable "mxroute" {
  type = object({
    server = optional(string)
    email  = optional(bool, false)
  })
  default     = {}
  description = "Configure options to connect the domain to MXRoute."
}

variable "google" {
  type = object({
    verification = optional(string)
    gmail        = optional(bool, false)
  })
  default     = {}
  description = "Configures options to connect the domain to Google."
}

variable "apple" {
  type = object({
    verification = optional(string)
  })
  default     = {}
  description = "Configures options to connect the domain to Apple."
}

variable "facebook" {
  type = object({
    verification = optional(string)
  })
  default     = {}
  description = "Configure options to connect the domain to Facebook."
}
