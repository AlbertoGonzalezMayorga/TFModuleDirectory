###############
## Route53 Zones & Records ##
###############

variable "delegations" {
  description = <<EOT
        NS delegations (optional). Creates an NS record in the parent zone pointing to the name servers of the child zone.

        - parent_zone_id: zone_id of the parent zone
        - child_zone_key: key within var.zones (child zone)
        - name: (optional) record name in the parent; by default uses the child zone name
        - ttl: TTL for the NS
        - name_servers: (optional) if not provided, will try to use the name_servers from the child zone (created or found)
        EOT

  type = list(object({
    parent_zone_id  = string
    child_zone_key  = string
    name            = optional(string)
    ttl             = optional(number, 300)
    allow_overwrite = optional(bool, false)
    name_servers    = optional(list(string))
  }))

  default = []
}

variable "records" {
  description = <<EOT
        List of records to create.

        Requires:
        - Either zone_key (key within var.zones)
        - Or zone_id (if you don't want to reference by zone_key)

        Supports:
        - "Classic" records (ttl + records)
        - alias (for A/AAAA ALIAS)
        - routing policies (weighted/latency/failover/geolocation/multivalue)

        Notes:
        - If name="@" and zone_key is used, it will be converted to the zone apex.
        EOT

  type = list(object({
    zone_key = optional(string)
    zone_id  = optional(string)

    name = string
    type = string

    ttl             = optional(number)
    records         = optional(list(string))
    allow_overwrite = optional(bool, false)

    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = optional(bool, false)
    }))

    health_check_id = optional(string)
    set_identifier  = optional(string)

    routing_policy = optional(object({
      weighted = optional(object({
        weight = number
      }))
      latency = optional(object({
        region = string
      }))
      failover = optional(object({
        type = string #Options:  PRIMARY | SECONDARY
      }))
      geolocation = optional(object({
        continent   = optional(string)
        country     = optional(string)
        subdivision = optional(string)
      }))
      multivalue_answer = optional(bool)
    }))
  }))

  validation {
    condition = alltrue([
      for r in var.records : (
        (try(r.zone_key, null) != null) || (try(r.zone_id, null) != null)
      )
    ])
    error_message = "Each record must specify zone_key or zone_id."
  }

  default = null
}

variable "tags" {
  description = "Common tags for the module."
  type        = map(string)
  default     = {}
}

variable "zones" {
  description = <<EOT
        Map of zones to manage.

        - If create=true (default), the zone is created.
        - If create=false:
        - if zone_id is provided, that zone_id is used
        - if zone_id is NOT provided, a lookup is done by name (+ private flag and, if applicable, the first VPC)

        Example:
        zones = {
        public_main = {
            name   = "example.com"
            private = false
        }
        private_app = {
            name    = "internal.example.com"
            private = true
            vpcs = [{ vpc_id = "vpc-123", vpc_region = "us-east-1" }]
        }
        }
        EOT

  type = map(object({
    name          = string
    comment       = optional(string)
    force_destroy = optional(bool, false)
    tags          = optional(map(string), {})
    private       = optional(bool, false)
    vpcs = optional(list(object({
      vpc_id     = string
      vpc_region = optional(string)
    })), [])
    delegation_set_id = optional(string)

    create  = optional(bool, true)
    zone_id = optional(string)
  }))

  default = null
}