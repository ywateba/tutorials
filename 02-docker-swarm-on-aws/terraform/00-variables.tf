variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default = "docker-swarm-vpc"
}

variable "number_of_azs" {
  description = "Number of availability zones"
  type        = number
  default = 3
}


variable "min_managers" {
  description = "Minimum number of manager nodes"
  type        = number
  default = 1
}

variable "max_managers" {
  description = "Maximum number of manager nodes"
  type        = number
  default = 3
}

variable "min_workers" {
  description = "Minimum number of worker nodes"
  type        = number
  default = 2
}

variable "max_workers" {
  description = "Maximum number of worker nodes"
  type        = number
  default = 6
}


variable "defaut_ami" {
  description = "Default AMI to use for the instances"
  type        = string
  default = "ami-01816d07b1128cd2d"
  
}