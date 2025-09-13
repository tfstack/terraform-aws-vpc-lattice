variable "listeners" {
  description = "Map of listeners to create"
  type = map(object({
    name               = string
    protocol           = string
    port               = number
    service_identifier = string
    target_groups = list(object({
      target_group_identifier = string
      weight                  = number
    }))
    default_action = optional(object({
      target_group_identifier = string
      weight                  = number
    }))
    tags = optional(map(string), {})
  }))
}

variable "listener_rules" {
  description = "List of listener rules to create"
  type = list(object({
    service_name            = string
    priority                = number
    service_identifier      = string
    target_group_identifier = string
    match = optional(object({
      http_match = optional(object({
        header_name     = optional(string)
        header_value    = optional(string)
        method          = optional(string)
        path            = string
        path_match_type = optional(string, "exact") # exact, prefix
      }))
    }))
    action = optional(object({
      weight = optional(number, 1)
    }))
    tags = optional(map(string), {})
  }))
  default = []
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
