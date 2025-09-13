variable "target_groups" {
  description = "Map of target groups to create"
  type = map(object({
    name                           = string
    type                           = string
    protocol                       = string
    port                           = number
    vpc_id                         = string
    lambda_event_structure_version = optional(string, "V1")
    targets = optional(list(object({
      target_id = string
      port      = optional(number)
    })), [])
    health_check = optional(object({
      path                = string
      interval            = optional(number, 30)
      timeout             = optional(number, 5)
      healthy_threshold   = optional(number, 2)
      unhealthy_threshold = optional(number, 2)
    }))
    tags = optional(map(string), {})
  }))
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
