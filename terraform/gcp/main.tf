terraform {
  backend "gcs" { }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.28.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.28.0"
    }
    # local = {
    #   source = "hashicorp/local"
    #   version  = "~> 2.5.1"
    # }
    # helm = {
    #   source = "hashicorp/helm"
    #   version  = "~> 2.13.2"
    # }
  }
}

provider "google" {
  project = var.project
  region  = var.region

  scopes = [
    # Default scopes
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    "https://www.googleapis.com/auth/devstorage.full_control",

    # Required for google_client_openid_userinfo
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}

provider "google-beta" {
  project = var.project
  region  = var.region

  scopes = [
    # Default scopes
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    "https://www.googleapis.com/auth/devstorage.full_control",

    # Required for google_client_openid_userinfo
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}

module "networking" {
  source = "../modules/gcp/vpc-network"

  name_prefix           = "${var.building_block}-${var.env}"
  project               = var.project
  region                = var.region

  cidr_block            = var.vpc_cidr_block
  secondary_cidr_block  = var.vpc_secondary_cidr_block

  public_subnetwork_secondary_range_name = var.public_subnetwork_secondary_range_name
  public_services_secondary_range_name   = var.public_services_secondary_range_name
  public_services_secondary_cidr_block   = var.public_services_secondary_cidr_block
  private_services_secondary_cidr_block  = var.private_services_secondary_cidr_block
  secondary_cidr_subnetwork_width_delta  = var.secondary_cidr_subnetwork_width_delta
  secondary_cidr_subnetwork_spacing      = var.secondary_cidr_subnetwork_spacing

  igw_cidr              = var.igw_cidr
}

module "cloud_storage" {
  source          = "../modules/gcp/cloud-storage"
  building_block  = var.building_block
  env             = var.env
  project         = var.project
  region          = var.region
}

module "gke_service_account"{
  source = "../modules/gcp/service-account"
  name        = "${var.building_block}-${var.cluster_service_account_name}"
  project     = var.project
  description = var.cluster_service_account_description
  service_account_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer"
  ]
}

module "gke_cluster" {
  source = "../modules/gcp/gke-cluster"

  building_block                = var.building_block
  env                           = var.env

  name                          = "${var.building_block}-${var.env}-cluster"
  project                       = var.project
  location                      = var.zone # can also specify a region here
  zone                          = var.zone # has to be a zone, else one instance per zone will be created in the region.
  network                       = module.networking.network

  subnetwork                    = module.networking.public_subnetwork
  cluster_secondary_range_name  = module.networking.public_subnetwork_secondary_range_name
  services_secondary_range_name = module.networking.public_services_secondary_range_name

  # When creating a private cluster, the 'master_ipv4_cidr_block' has to be defined and the size must be /28
  master_ipv4_cidr_block        = var.gke_master_ipv4_cidr_block

  # This setting will make the cluster private
  enable_private_nodes          = "true"

  # To make testing easier, we keep the public endpoint available. In production, we highly recommend restricting access to only within the network boundary, requiring your users to use a bastion host or VPN.
  disable_public_endpoint       = "false"

  # With a private cluster, it is highly recommended to restrict access to the cluster master
  # However, for testing purposes we will allow all inbound traffic.
  master_authorized_networks_config = [
    {
      cidr_blocks = [
        {
          cidr_block   = var.igw_cidr[0]
          display_name = "IGW"
        },
      ]
    },
  ]

  gke_node_pool_network_tags = [
    module.networking.public
  ]

  gke_node_pool_instance_type     = var.gke_node_pool_instance_type
  gke_node_pool_scaling_config    = var.gke_node_pool_scaling_config

  enable_vertical_pod_autoscaling = var.enable_vertical_pod_autoscaling

  alternative_default_service_account = var.override_default_node_pool_service_account ? module.gke_service_account.email : null

  resource_labels = {
    environment = var.env
  }
}

resource "null_resource" "configure_kubectl" {
  provisioner "local-exec" {

    command = "gcloud container clusters get-credentials ${module.gke_cluster.name} --region ${var.zone} --project ${var.project}"


    # Use environment variables to allow custom kubectl config paths
    environment = {
      KUBECONFIG = var.kubectl_config_path != "" ? var.kubectl_config_path : "credentials/config-${var.building_block}-${var.env}.yaml"
    }
  }

  depends_on = [ module.gke_cluster ]
}

module "command_service_sa_iam_role" {
  source = "../modules/gcp/service-account"
  name        = "${var.building_block}-${var.command_api_sa_iam_role_name}"
  project     = var.project
  description = "GCP SA bound to K8S SA ${var.project}[${var.command_api_namespace}-sa]"
  service_account_roles = [
    "roles/storage.objectAdmin"
  ]
  sa_namespace = var.command_api_namespace
  sa_name = "${var.command_api_namespace}-sa"
  depends_on = [ module.gke_cluster ]
}

module "dataset_api_sa_iam_role" {
  source = "../modules/gcp/service-account"
  name        = "${var.building_block}-${var.dataset_api_sa_iam_role_name}"
  project     = var.project
  description = "GCP SA bound to K8S SA ${var.project}[${var.dataset_api_namespace}-sa]"
  service_account_roles = [
    "roles/storage.objectAdmin"
  ]
  sa_namespace = var.dataset_api_namespace
  sa_name = "${var.dataset_api_namespace}-sa"
  depends_on = [ module.gke_cluster ]
  google_service_account_key_path = "${path.module}/credentials/dataset-api-service-account-key.json"
}

module "flink_sa_iam_role" {
  source = "../modules/gcp/service-account"
  name        = "${var.building_block}-${var.flink_sa_iam_role_name}"
  project     = var.project
  description = "GCP SA bound to K8S SA ${var.project}[${var.flink_namespace}-sa]"
  service_account_roles = [
    "roles/storage.objectAdmin"
  ]
  sa_namespace = var.flink_namespace
  sa_name = "${var.flink_namespace}-sa"
  depends_on = [ module.gke_cluster ]
}

module "druid_raw_sa_iam_role" {
  source = "../modules/gcp/service-account"
  name        = "${var.building_block}-${var.druid_raw_sa_iam_role_name}"
  project     = var.project
  description = "GCP SA bound to K8S SA ${var.project}[${var.druid_raw_namespace}-sa]"
  service_account_roles = [
    "roles/storage.objectAdmin"
  ]
  sa_namespace = var.druid_raw_namespace
  sa_name = "${var.druid_raw_namespace}-sa"
  depends_on = [ module.gke_cluster ]
}

module "secor_sa_iam_role" {
  source = "../modules/gcp/service-account"
  name        = "${var.building_block}-${var.secor_sa_iam_role_name}"
  project     = var.project
  description = "GCP SA bound to K8S SA ${var.project}[${var.secor_namespace}-sa]"
  service_account_roles = [
    "roles/storage.objectAdmin"
  ]
  sa_namespace = var.secor_namespace
  sa_name = "${var.secor_namespace}-sa"
  depends_on = [ module.gke_cluster ]
}

module "velero_sa_iam_role" {
  source = "../modules/gcp/service-account"
  name        = "${var.building_block}-${var.velero_sa_iam_role_name}"
  project     = var.project
  description = "GCP SA bound to K8S SA ${var.project}[${var.velero_namespace}-sa]"
  service_account_roles = [
    "roles/compute.storageAdmin",
    "roles/storage.objectAdmin",
    "roles/iam.serviceAccountTokenCreator"
  ]
  sa_namespace = var.velero_namespace
  sa_name = "${var.velero_namespace}-sa"
  depends_on = [ module.gke_cluster ]
}

module "postgresql_backup_sa_iam_role" {
  source = "../modules/gcp/service-account"
  name        = "${var.building_block}-${var.postgresql_backup_sa_iam_role_name}"
  project     = var.project
  description = "GCP SA bound to K8S SA ${var.project}[${var.postgresql_namespace}-sa]"
  service_account_roles = [
    "roles/storage.objectAdmin"
  ]
  sa_namespace = var.postgresql_namespace
  sa_name = "${var.postgresql_namespace}-backup-sa"
  depends_on = [ module.gke_cluster ]
}

module "redis_backup_sa_iam_role" {
  source = "../modules/gcp/service-account"
  name        = "${var.building_block}-${var.redis_backup_sa_iam_role_name}"
  project     = var.project
  description = "GCP SA bound to K8S SA ${var.project}[${var.redis_namespace}-sa]"
  service_account_roles = [
    "roles/storage.objectAdmin"
  ]
  sa_namespace = var.redis_namespace
  sa_name = "${var.redis_namespace}-backup-sa"
  depends_on = [ module.gke_cluster ]
}

module "spark_sa_iam_role" {
  source = "../modules/gcp/service-account"
  name        = "${var.building_block}-${var.spark_sa_iam_role_name}"
  project     = var.project
  description = "GCP SA bound to K8S SA ${var.project}[${var.spark_namespace}-sa]"
  service_account_roles = [
    "roles/storage.objectAdmin"
  ]
  sa_namespace = var.spark_namespace
  sa_name = "${var.spark_namespace}-sa"
  depends_on = [ module.gke_cluster ]
}

# resource "google_storage_bucket_object" "kubeconfig" {
#   name   = "kubeconfig/config-${var.building_block}-${var.env}.yaml"
#   source = var.kubectl_config_path != "" ? var.kubectl_config_path : ""
#   bucket = "${var.project}-${var.env}-configs"
#   depends_on = [ null_resource.configure_kubectl ]
# }

# We use this data provider to expose an access token for communicating with the GKE cluster.
data "google_client_config" "client" {}

# # Use this datasource to access the Terraform account's email for Kubernetes permissions.
data "google_client_openid_userinfo" "terraform_user" {}

# # resource "kubernetes_cluster_role_binding" "user" {
# #   metadata {
# #     name = "admin-user"
# #   }

# #   role_ref {
# #     kind      = "ClusterRole"
# #     name      = "cluster-admin"
# #     api_group = "rbac.authorization.k8s.io"
# #   }

# #   subject {
# #     kind      = "User"
# #     name      = data.google_client_openid_userinfo.terraform_user.email
# #     api_group = "rbac.authorization.k8s.io"
# #   }

# #   subject {
# #     kind      = "Group"
# #     name      = "system:masters"
# #     api_group = "rbac.authorization.k8s.io"
# #   }
# # }

provider "kubernetes" {
  host                   = module.gke_cluster.endpoint
  token                  = data.google_client_config.client.access_token
  cluster_ca_certificate = module.gke_cluster.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = module.gke_cluster.endpoint
    token                  = data.google_client_config.client.access_token
    cluster_ca_certificate = module.gke_cluster.cluster_ca_certificate
  }
}

# data "templatefile" "gke_host_endpoint" {
#   template = module.gke_cluster.endpoint
# }

# data "templatefile" "access_token" {
#   template = data.google_client_config.client.access_token
# }

# data "templatefile" "cluster_ca_certificate" {
#   template = module.gke_cluster.cluster_ca_certificate
# }

# module "monitoring" {
#   source                           = "../modules/helm/monitoring"
#   env                              = var.env
#   building_block                   = var.building_block
#   depends_on                       = [ module.gke_cluster ]
#   monitoring_grafana_oauth_configs = var.monitoring_grafana_oauth_configs
#   s3_backups_bucket                = module.cloud_storage.google_backups_bucket
# }

# module "loki" {
#   source         = "../modules/helm/loki"
#   env            = var.env
#   building_block = var.building_block
#   depends_on     = [ module.gke_cluster, module.monitoring ]
# }

# module "promtail" {
#   source                    = "../modules/helm/promtail"
#   env                       = var.env
#   building_block            = var.building_block
#   promtail_chart_depends_on = [ module.loki ]
# }

# module "grafana_configs" {
#   source                           = "../modules/helm/grafana_configs"
#   env                              = var.env
#   building_block                   = var.building_block
#   grafana_configs_chart_depends_on = [ module.monitoring ]
# }

# module "postgresql" {
#   source               = "../modules/helm/postgresql"
#   env                  = var.env
#   building_block       = var.building_block
#   depends_on           = [ module.gke_cluster ]
# }

# module "redis" {
#   source                       = "../modules/helm/redis"
#   env                          = var.env
#   building_block               = var.building_block
#   depends_on                   = [ module.gke_cluster, module.kubernetes_reflector ]
#   cloud_store_provider         = "gcs"
#   redis_backup_gcs_bucket      = module.cloud_storage.google_backups_bucket
#   redis_backup_sa_annotations  = "iam.gke.io/gcp-service-account: ${var.building_block}-${var.redis_backup_sa_iam_role_name}@${var.project}.iam.gserviceaccount.com"
#   redis_namespace              = var.redis_namespace
#   docker_registry_secret_name  = module.kubernetes_reflector.docker_registry_secret_name
# }

# module "kafka" {
#   source         = "../modules/helm/kafka"
#   env            = var.env
#   building_block = var.building_block
#   depends_on     = [ module.gke_cluster ]
# }

# module "superset" {
#   source                            = "../modules/helm/superset"
#   env                               = var.env
#   building_block                    = var.building_block
#   postgresql_admin_username         = module.postgresql.postgresql_admin_username
#   postgresql_admin_password         = module.postgresql.postgresql_admin_password
#   postgresql_superset_user_password = module.postgresql.postgresql_superset_user_password
#   superset_chart_depends_on         = [ module.postgresql, module.redis_dedup ]
#   redis_namespace                   = module.redis_dedup.redis_namespace
#   redis_release_name                = module.redis_dedup.redis_release_name
#   postgresql_service_name           = module.postgresql.postgresql_service_name
#   oauth_configs                     = var.oauth_configs
#   web_console_base_url              = var.kong_ingress_domain != "" ? var.kong_ingress_domain : "${module.eip.kong_ingress_ip.public_ip}.sslip.io"
#   superset_base_url                 = var.kong_ingress_domain != "" ? var.kong_ingress_domain : "${module.eip.kong_ingress_ip.public_ip}.sslip.io"
# }

# module "flink" {
#   source                               = "../modules/helm/flink"
#   env                                  = var.env
#   building_block                       = var.building_block
#   flink_container_registry             = var.flink_container_registry
#   flink_release_names                  = var.flink_release_names
#   flink_unified_pipeline_release_names = var.flink_unified_pipeline_release_names
#   unified_pipeline_enabled              = var.unified_pipeline_enabled
#   flink_image_tag                      = var.flink_image_tag
#   flink_checkpoint_store_type          = var.flink_checkpoint_store_type
#   flink_chart_depends_on               = [ module.kafka, module.redis_dedup, module.redis_denorm, module.postgresql ]
#   postgresql_obsrv_username            = module.postgresql.postgresql_obsrv_username
#   postgresql_obsrv_user_password       = module.postgresql.postgresql_obsrv_user_password
#   postgresql_obsrv_database            = module.postgresql.postgresql_obsrv_database
#   checkpoint_base_url                  = "gs://${module.cloud_storage.checkpoint_storage_bucket}"
#   denorm_redis_namespace               = module.redis_denorm.redis_namespace
#   denorm_redis_release_name            = module.redis_denorm.redis_release_name
#   dedup_redis_namespace                = module.redis_dedup.redis_namespace
#   dedup_redis_release_name             = module.redis_dedup.redis_release_name
#   flink_sa_annotations                 = "iam.gke.io/gcp-service-account: ${var.building_block}-${var.flink_sa_iam_role_name}@${var.project}.iam.gserviceaccount.com"
#   flink_namespace                      = var.flink_namespace
#   depends_on                           = [ module.flink_sa_iam_role ]
# }

# module "druid_operator" {
#   source          = "../modules/helm/druid_operator"
#   env             = var.env
#   building_block  = var.building_block
#   depends_on      = [ module.gke_cluster ]
# }

# module "druid_raw_cluster" {
#   source                             = "../modules/helm/druid_raw_cluster"
#   env                                = var.env
#   building_block                     = var.building_block
#   gcs_bucket                         = module.cloud_storage.name
#   druid_deepstorage_type             = var.druid_deepstorage_type
#   druid_raw_cluster_chart_depends_on = [ module.postgresql, module.druid_operator ]
#   kubernetes_storage_class           = var.kubernetes_storage_class_raw
#   druid_raw_user_password            = module.postgresql.postgresql_druid_raw_user_password
#   druid_raw_sa_annotations           = "iam.gke.io/gcp-service-account: ${var.building_block}-${var.druid_raw_sa_iam_role_name}@${var.project}.iam.gserviceaccount.com"
#   druid_cluster_namespace            = var.druid_raw_namespace
#   depends_on                         = [ module.druid_raw_sa_iam_role ]
# }

# module "kafka_exporter" {
#   source                          = "../modules/helm/kafka_exporter"
#   env                             = var.env
#   building_block                  = var.building_block
#   kafka_exporter_chart_depends_on = [ module.kafka, module.monitoring ]
# }

# module "postgresql_exporter" {
#   source                               = "../modules/helm/postgresql_exporter"
#   env                                  = var.env
#   building_block                       = var.building_block
#   postgresql_exporter_chart_depends_on = [ module.postgresql, module.monitoring ]
# }

# module "druid_exporter" {
#   source                          = "../modules/helm/druid_exporter"
#   env                             = var.env
#   building_block                  = var.building_block
#   druid_exporter_chart_depends_on = [ module.druid_raw_cluster, module.monitoring ]
# }

# module "dataset_api" {
#   source                             = "../modules/helm/dataset_api"
#   env                                = var.env
#   building_block                     = var.building_block
#   dataset_api_container_registry     = var.dataset_api_container_registry
#   dataset_api_image_name             = var.dataset_api_image_name
#   dataset_api_image_tag              = var.dataset_api_image_tag
#   postgresql_obsrv_username          = module.postgresql.postgresql_obsrv_username
#   postgresql_obsrv_user_password     = module.postgresql.postgresql_obsrv_user_password
#   postgresql_obsrv_database          = module.postgresql.postgresql_obsrv_database
#   dataset_api_sa_annotations         = "iam.gke.io/gcp-service-account: ${var.building_block}-${var.dataset_api_sa_iam_role_name}@${var.project}.iam.gserviceaccount.com"
#   dataset_api_chart_depends_on       = [ module.postgresql, module.kafka ]
#   denorm_redis_namespace             = module.redis_denorm.redis_namespace
#   denorm_redis_release_name          = module.redis_denorm.redis_release_name
#   dedup_redis_namespace              = module.redis_dedup.redis_namespace
#   dedup_redis_release_name           = module.redis_dedup.redis_release_name
#   dataset_api_namespace              = var.dataset_api_namespace
#   depends_on                         = [ module.dataset_api_sa_iam_role ]
#   docker_registry_secret_name        = module.kubernetes_reflector.docker_registry_secret_name
# }

# module "secor" {
#   source                  = "../modules/helm/secor"
#   env                     = var.env
#   building_block          = var.building_block
#   kubernetes_storage_class = var.kubernetes_storage_class_raw
#   secor_sa_annotations    = "iam.gke.io/gcp-service-account: ${var.building_block}-${var.secor_sa_iam_role_name}@${var.project}.iam.gserviceaccount.com"
#   secor_chart_depends_on  = [ module.kafka ]
#   secor_namespace         = var.secor_namespace
#   cloud_store_provider    = "GS"
#   cloud_storage_bucket    = module.cloud_storage.name
#   upload_manager          = "com.pinterest.secor.uploader.GsUploadManager"
#   depends_on              = [ module.secor_sa_iam_role ]
# }

# module "submit_ingestion" {
#   source                            = "../modules/helm/submit_ingestion"
#   env                               = var.env
#   building_block                    = var.building_block
#   submit_ingestion_chart_depends_on = [ module.kafka, module.druid_raw_cluster ]
# }

# module "velero" {
#   source                       = "../modules/helm/velero"
#   env                          = var.env
#   gcp_project_id               = var.project
#   building_block               = var.building_block
#   cloud_provider               = "gcp"
#   velero_backup_bucket         = module.cloud_storage.velero_storage_bucket
#   velero_backup_bucket_region  = var.region
#   velero_sa_iam_role_name      = var.velero_sa_iam_role_name
#   velero_sa_annotations        = "iam.gke.io/gcp-service-account: ${var.building_block}-${var.velero_sa_iam_role_name}@${var.project}.iam.gserviceaccount.com"
#   depends_on                   = [ module.velero_sa_iam_role ]
# }

# module "alert_rules" {
#   source                       = "../modules/helm/alert_rules"
#   alertrules_chart_depends_on  = [ module.monitoring ]
# }

# module "web_console" {
#   source                           = "../modules/helm/web_console"
#   env                              = var.env
#   building_block                   = var.building_block
#   web_console_configs              = var.web_console_configs
#   depends_on                       = [ module.gke_cluster, module.monitoring, module.superset ]
#   web_console_image_repository     = var.web_console_image_repository
#   web_console_image_tag            = var.web_console_image_tag
#   docker_registry_secret_name      = module.kubernetes_reflector.docker_registry_secret_name
# }

# module "volume_autoscaler" {
#   source         = "../modules/helm/volume_autoscaler"
#   env            = var.env
#   building_block = var.building_block
#   depends_on     = [ module.gke_cluster ]
# }

# module "command_service" {
#   source                              = "../modules/helm/command_service"
#   env                                 = var.env
#   command_service_chart_depends_on    = [ module.flink, module.postgresql, module.druid_raw_cluster, module.kubernetes_reflector ]
#   command_service_image_tag           = var.command_service_image_tag
#   postgresql_obsrv_username           = module.postgresql.postgresql_obsrv_username
#   postgresql_obsrv_user_password      = module.postgresql.postgresql_obsrv_user_password
#   postgresql_obsrv_database           = module.postgresql.postgresql_obsrv_database
#   druid_cluster_release_name          = module.druid_raw_cluster.druid_cluster_release_name
#   druid_cluster_namespace             = module.druid_raw_cluster.druid_cluster_namespace
#   flink_namespace                     = module.flink.flink_namespace
#   docker_registry_secret_name         = module.kubernetes_reflector.docker_registry_secret_name
# }

# module "postgresql_backup" {
#   source                              = "../modules/helm/postgresql_backup"
#   env                                 = var.env
#   building_block                      = var.building_block
#   postgresql_backup_postgres_user     = module.postgresql.postgresql_admin_username
#   postgresql_backup_postgres_host     = module.postgresql.postgresql_service_name
#   postgresql_backup_postgres_password = module.postgresql.postgresql_admin_password
#   cloud_store_provider                = "gcs"
#   postgresql_backup_gcs_bucket        = module.cloud_storage.google_backups_bucket
#   postgresql_backup_sa_annotations    = "iam.gke.io/gcp-service-account: ${var.building_block}-${var.postgresql_backup_sa_iam_role_name}@${var.project}.iam.gserviceaccount.com"
#   postgresql_backup_namespace         = var.postgresql_namespace
#   depends_on                          = [ module.gke_cluster,  module.kubernetes_reflector ]
#   docker_registry_secret_name         = module.kubernetes_reflector.docker_registry_secret_name
# }

# module "kubernetes_reflector" {
#   source                                    = "../modules/helm/kubernetes_reflector"
#   env                                       = var.env
#   building_block                            = var.building_block
#   docker_registry_secret_dockerconfigjson   = var.docker_registry_secret_dockerconfigjson
#   depends_on                                = [ module.gke_cluster ]
# }
