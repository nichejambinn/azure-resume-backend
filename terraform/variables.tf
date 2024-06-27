variable "default_tags" {
  default = {
    Environment = "dev"
    Owner       = "nichejambinn"
    Project     = "Resume Backend"
  }
  description = "Default Tags for Resume"
  type        = map(string)
}
