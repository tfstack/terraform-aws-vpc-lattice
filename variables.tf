variable "create_service_network" {
  description = "Whether to create a new service network or use existing one"
  type        = bool
  default     = true
}

variable "service_network_id" {
  description = "ID of existing service network to use when create_service_network is false"
  type        = string
  default     = null
}

variable "service_network" {
  description = "Configuration for the VPC Lattice service network"
  type = object({
    name      = string
    auth_type = string
    log_config = optional(object({
      destination_arn = optional(string)
    }))
    auth_policy = optional(string)
    tags        = optional(map(string), {})
  })
}

variable "vpc_associations" {
  description = "List of VPCs to associate with the service network"
  type = list(object({
    vpc_id             = string
    security_group_ids = optional(list(string))
    tags               = optional(map(string), {})
  }))
  default = []
}

variable "services" {
  description = "List of VPC Lattice services with their associated target groups"
  type = list(object({
    name      = string
    protocol  = string
    port      = number
    auth_type = string

    # Native VPC Lattice custom domain support
    custom_name = optional(string)

    # Target groups for weighted routing
    target_groups = list(object({
      name                           = string
      type                           = string
      protocol                       = optional(string) # Required for INSTANCE/ALB/IP, optional for LAMBDA
      port                           = optional(number) # Required for INSTANCE/ALB/IP, optional for LAMBDA
      vpc_id                         = optional(string) # Required for INSTANCE/ALB/IP, optional for LAMBDA
      weight                         = optional(number, 1)
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

    # Service-specific configuration
    default_action = optional(object({
      target_group_name = string
      weight            = optional(number, 1)
    }))
    listener_rules = optional(list(object({
      priority          = number
      target_group_name = optional(string) # Allow rules to specify which target group to route to
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
    })), [])

    # Auth policy configuration (optional - for custom policies)
    auth_policy = optional(string)

    # Access logging configuration (optional)
    log_config = optional(object({
      destination_arn = optional(string)
    }))

    tags = optional(map(string), {})
  }))
  default = []

  # Validation rule for target group requirements
  validation {
    condition = alltrue([
      for service in var.services :
      alltrue([
        for tg in service.target_groups :
        (tg.type == "LAMBDA") ||
        (tg.type != "LAMBDA" && tg.protocol != null && tg.port != null && tg.vpc_id != null)
      ])
    ])
    error_message = "INSTANCE, ALB, and IP target groups must have protocol, port, and vpc_id. LAMBDA target groups can omit these fields."
  }

  validation {
    condition = alltrue([
      for service in var.services :
      alltrue([
        for tg in service.target_groups :
        (tg.type != "LAMBDA") ||
        (tg.type == "LAMBDA" && contains(["V1", "V2"], tg.lambda_event_structure_version))
      ])
    ])
    error_message = "LAMBDA target groups must have lambda_event_structure_version set to either 'V1' or 'V2'."
  }

  validation {
    condition = alltrue([
      for service in var.services :
      alltrue([
        for rule in service.listener_rules :
        rule.priority >= 1 && rule.priority <= 100
      ])
    ])
    error_message = "Listener rule priority must be between 1 and 100 (inclusive)."
  }

  validation {
    condition = alltrue([
      for service in var.services :
      alltrue([
        for rule in service.listener_rules :
        rule.match == null || rule.match.http_match == null || (
          (rule.match.http_match.header_name == null && rule.match.http_match.header_value == null) ||
          (rule.match.http_match.header_name != null && rule.match.http_match.header_value != null)
        )
      ])
    ])
    error_message = "If header_name is provided in listener rules, header_value must also be provided (and vice versa). Both are required for header matching."
  }

  # Validation rule to prevent logging conflicts
  validation {
    condition = !var.enable_resource_access_logs || alltrue([
      for service in var.services :
      service.log_config == null
    ])
    error_message = "Cannot enable resource access logs when ANY service has log_config (service access logs). AWS VPC Lattice only allows one type of access log subscription per resource. Either remove log_config from all services OR set enable_resource_access_logs = false."
  }
}

# Note: IAM policies for VPC Lattice services are managed through AWS IAM
# and attached to the service using the AWS CLI or SDK
# The aws_vpclattice_service_policy resource is not available in the AWS provider

variable "create_log_group" {
  description = "Whether to create a CloudWatch log group for VPC Lattice logs"
  type        = bool
  default     = false
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group for VPC Lattice logs"
  type        = string
  default     = "/aws/vpclattice"
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

variable "log_group_prevent_destroy" {
  description = "Whether to prevent destruction of the CloudWatch log group"
  type        = bool
  default     = true
}

variable "create_per_service_log_groups" {
  description = "Whether to create individual CloudWatch log groups for each service"
  type        = bool
  default     = false
}

variable "enable_resource_access_logs" {
  description = "Whether to enable resource access logs for VPC Lattice resources (API calls, management operations)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

# Route 53 Configuration for Custom Domains
variable "create_route53_zone" {
  description = "Whether to create a Route 53 zone for custom domains"
  type        = bool
  default     = false
}

variable "route53_zone_name" {
  description = "Name of the Route 53 zone to create (e.g., 'internal')"
  type        = string
  default     = null
}

variable "route53_vpc_ids" {
  description = "List of VPC IDs to associate with the Route 53 zone"
  type        = list(string)
  default     = []
}

variable "route53_zone_tags" {
  description = "Tags for the Route 53 zone"
  type        = map(string)
  default     = {}
}

variable "log_group_name_prefix" {
  description = "Prefix for CloudWatch log group names to avoid conflicts when multiple module instances are used"
  type        = string
  default     = "/aws/vpclattice"
}

variable "service_network_log_group_name" {
  description = "Name for the service network access log group (defaults to using log_group_name_prefix + service network name)"
  type        = string
  default     = null
}

variable "service_log_group_name_prefix" {
  description = "Prefix for service-specific log group names"
  type        = string
  default     = null
}

variable "resource_log_group_name_prefix" {
  description = "Prefix for resource access log group names"
  type        = string
  default     = null
}
