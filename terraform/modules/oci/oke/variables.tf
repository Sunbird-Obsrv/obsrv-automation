variable "compartment_id" {
    description = "Compartment created on OCI same as that of IAM in AWS"
}
variable "tenancy_ocid" {
    description = "Oracle-assigned unique ID"
}
variable "user_ocid" {
    description = " the OCID of the user for whom the key pair is being added"
}
variable "private_key_path" {
    description = "Path to private key to access OCI in your local system"
}
variable "fingerprint" {
    description = "The fingerprint of the key"
}
variable "region" {
    description = "Region in which you want you infrastruture to be created"
}
variable "image_id" {
    description = "Image ID of the Linux distribution you want to use for OKE creation"
}
variable "subnet_id" {
    description = "Subnet to be used in VCN creation"
}