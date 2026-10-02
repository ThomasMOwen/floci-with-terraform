variable "env_name" {
  description = "The name of the environment"
  type        = string
}

variable "owner" {
  description = "The owner of the environment"
  type        = string
}

variable "applications" {
  description = "A key value list of applications, will be converted to a map"
  type        = map(string)
}