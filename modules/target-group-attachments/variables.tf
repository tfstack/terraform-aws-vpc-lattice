variable "target_groups" {
  description = "Map of target group configurations"
  type = map(object({
    name     = string
    type     = string
    protocol = string
    port     = number
    vpc_id   = string
    targets = optional(list(object({
      target_id = string
      port      = optional(number)
    })), [])
    tags = optional(map(string), {})
  }))
}

variable "target_group_ids" {
  description = "Map of target group names to IDs"
  type        = map(string)
}
