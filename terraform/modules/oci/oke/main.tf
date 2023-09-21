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

resource "oci_identity_compartment" "obsrv_env" {
  compartment_id = var.compartment_id
  description    = "obsrv_env"
  name           = "obsrv_env"
}

resource "oci_containerengine_cluster" "obsrv_env" {
  provider           = oci.oke
  compartment_id     = oci_identity_compartment.obsrv_env.id
  name               = "obsrv_env"
  kubernetes_version = "v1.27.2"
  vcn_id             = module.vcn.vcn_id
}

data "oci_identity_availability_domains" "available_availability_domains" {
  compartment_id = var.compartment_id
}

resource "oci_containerengine_node_pool" "obsrv_np" {
  name           = "obsrv_np"
  compartment_id = var.compartment_id
  cluster_id     = oci_containerengine_cluster.obsrv_env.id
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

