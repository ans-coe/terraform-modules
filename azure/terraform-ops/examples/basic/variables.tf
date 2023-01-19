variable "location" {
  description = "The location of this deployment."
  type        = string
  default     = "uksouth"
}

variable "tags" {
  description = "Tags given to the resources created by this template."
  type        = map(string)
  default = {
    module  = "terraform-ops"
    example = "basic"
    usage   = "demo"
  }
}
