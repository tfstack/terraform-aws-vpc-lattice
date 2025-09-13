############################################
# Variables
############################################

variable "services" {
  description = "Map of VPC Lattice services with their configurations"
  type        = map(any) # Use any to handle varying service structures
}

variable "service_arns" {
  description = "Map of service names to their ARNs"
  type        = map(string)
}

variable "tags" {
  description = "Default tags to apply to resources"
  type        = map(string)
  default     = {}
}
