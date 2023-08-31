variable "compartment_id" {}
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "private_key_path" {}
variable "fingerprint" {}
variable "region" {}
variable "image_id" {}
variable "source_id" {}
variable "subnet_id" {}
variable "ssh_authorized_keys" {}
variable "ssh_private_key" {}

variable "env" {
  type        = string
  description = "Environment name. All resources will be prefixed with this value."
  default     = "dev"
}

variable "building_block" {
  type        = string
  description = "Building block name. All resources will be prefixed with this value."
  default     = "obsrv"
}

