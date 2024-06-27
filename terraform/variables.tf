variable "default_tags" {
  default = {
    Environment = "dev"
    Owner       = "nichejambinn"
    Project     = "resume backend"
  }
  description = "default tags for resume"
  type        = map(string)
}
