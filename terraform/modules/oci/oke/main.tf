provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

provider "oci" {
  alias = "oke"
}

resource "oci_identity_compartment" "example" {
  compartment_id = var.compartment_id
  description    = "example"
  name           = "example"
}

resource "oci_containerengine_cluster" "example" {
  provider           = oci.oke
  compartment_id     = oci_identity_compartment.example.id
  name               = "example"
  kubernetes_version = "v1.27.2"
  vcn_id             = module.vcn.vcn_id
}

data "oci_identity_availability_domains" "available_availability_domains" {
  compartment_id = var.compartment_id
}

resource "oci_containerengine_node_pool" "default" {
  name           = "default"
  compartment_id = var.compartment_id
  cluster_id     = oci_containerengine_cluster.example.id
  node_shape     = "VM.Standard.E3.Flex"
  node_shape_config {
    memory_in_gbs = 32
    ocpus         = 2
  }
  node_source_details {
    image_id    = var.image_id
    source_type = "image"
  }
  node_config_details {
    size = 3
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.available_availability_domains.availability_domains[0].name
      subnet_id           = oci_core_subnet.vcn-private-subnet.id
    }
  }
  kubernetes_version = "v1.27.2"
}

