variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "name" {
  type        = string
  description = "Name given to the EKS cluster"
  default     = "online-boutique"
}
