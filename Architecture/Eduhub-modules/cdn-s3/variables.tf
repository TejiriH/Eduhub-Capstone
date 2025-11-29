# modules/storage/buckets/main.tf

variable "buckets" {
  description = "Map of bucket names to their configurations"
  type = map(object({
    versioning          = optional(bool, true)
    encryption          = optional(bool, true)
    lifecycle_rules     = optional(list(object({
      transition_days   = number
      storage_class     = string
    })), [])

  }))
}