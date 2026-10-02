variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "cluster_id" {
  description = "The ID of the cluster"
  type        = string
}

variable "applications" {
  description = "A map of applications to deploy"
  type        = map(string)
}