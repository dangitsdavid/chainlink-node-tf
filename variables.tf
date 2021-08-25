variable "node_min_size" {
  description = "The Chainlink node ASG minimum instance size."
  default     = 2
}

variable "node_max_size" {
  description = "The Chainlink node ASG max instance size."
  default     = 2
}

variable "node_desired_capacity" {
  description = "The Chainlink node ASG desired capacity."
  default     = 2
}

variable "instance_type" {
  description = "The instance type to use for the Chainlink container. It is recommended to use t3.medium and above."
  default     = "t3.micro"
}

variable "node_volume_size" {
  description = "The Chainlink node root volume size."
  default     = 30
}
