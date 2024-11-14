variable "env" {
  type        = string
  description = "Environment name. All resources will be prefixed with this value."
}

variable "building_block" {
  type        = string
  description = "Building block name. All resources will be prefixed with this value."
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the resources. These tags will be applied to all the resources."
  default     = {}
}

variable "region" {
  type        = string
  description = "AWS region to create the resources."
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR range"
  default     = "10.10.0.0/16"
}

variable "vpc_instance_tenancy" {
  type        = string
  description = "VPC tenancy type."
  default     = "default"
}

variable "availability_zones" {
  type        = list(string)
  description = "AWS Availability Zones."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDR values."
  default     = ["10.10.0.0/23", "10.10.4.0/23", "10.10.8.0/23"]
}

variable "auto_assign_public_ip" {
  type        = bool
  description = "Auto assign public ip's to instances in this subnet"
  default     = true
}

variable "igw_cidr" {
  type        = string
  description = "Internet gateway CIDR range."
  default     = "0.0.0.0/0"
}