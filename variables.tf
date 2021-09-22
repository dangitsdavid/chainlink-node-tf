variable "key_pair" {
  description = "The key pair to connect to instance."
  default     = "quickstart-staging"
}

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

variable "node_volume_size" {
  description = "The Chainlink node root volume size."
  default     = 30
}

variable "node_instance_type" {
  description = "The instance type to use for the Chainlink container. It is recommended to use t3.medium and above."
  default     = "t3.small"
}

variable "bastion_min_size" {
  description = "The bastion host ASG minimum instance size."
  default     = 1
}

variable "bastion_max_size" {
  description = "The bastion host ASG max instance size."
  default     = 2
}

variable "bastion_desired_capacity" {
  description = "The bastion host ASG desired capacity."
  default     = 1
}

variable "bastion_volume_size" {
  description = "The Chainlink node root volume size."
  default     = 10
}

variable "bastion_instance_type" {
  description = "The instance type to use for the Chainlink container. It is recommended to use t3.medium and above."
  default     = "t3.micro"
}

variable "db_username" {
  description = "The username for the PostgreSQL database"
  default     = "chainlinkuser"
}