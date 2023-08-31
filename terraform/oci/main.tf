terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
  }
}

# provider "helm" {
#   kubernetes {
#     
#   }
# }

# provider "helm" {
#     config_path = "~$HOME/.kube/config"
#     alias  = "helm"
#     kubernetes {
#         host                   = module.oke.kubernetes_endpoint
#         cluster_ca_certificate = module.oke.kubernetes_ca_cert
#         exec {
#             api_version = "client.authentication.k8s.io/v1beta1"
#             command     = "oci"
#             args        = ["k8s", "get-token", "--cluster-id", "${module.oke.cluster_id}"]
#         }
#     }
# }

   provider "helm" {  
       kubernetes {  
           config_path = "${path.root}/generated/kubeconfig"  
       }  
   }

module "oke" {
    source = "../modules/oci"
    image_id = var.image_id
    tenancy_ocid = var.tenancy_ocid
    user_ocid = var.user_ocid
    fingerprint = var.fingerprint
    source_id = var.source_id
    ssh_authorized_keys = var.ssh_authorized_keys
    ssh_private_key = var.ssh_private_key
    compartment_id = var.compartment_id
    private_key_path = var.private_key_path
    subnet_id = var.subnet_id
    region = var.region
}

