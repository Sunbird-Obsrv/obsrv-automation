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
variable "cluster_logs_enabled" {
  type = bool
  description = "Toggle to enable eks cluster logs"
}
variable "eks_cluster_logs_retention" {
  type = number
  description = "EKS cluster logs retention period"
  default = 1 
}

variable "eks_master_role" {
  type        = string
  description = "EKS control plane role name."
  default     = "eks_master_role"
}

variable "eks_nodes_role" {
  type        = string
  description = "EKS data plane role name.."
  default     = "eks_nodes_role"
}

variable "eks_node_group_name" {
  type        = string
  description = "EKS node group name."
  default     = "eks_node_group"
}

variable "eks_node_group_ami_type" {
  type        = string
  description = "EKS node group AMI type."
  default     = "AL2_x86_64"
}

variable "eks_node_group_instance_type" {
  type        = list(string)
  description = "EKS nodegroup instance types."
  default     = ["t2.xlarge"]
}

variable "eks_node_group_capacity_type" {
  type        = string
  description = "EKS node group type. Either SPOT or ON_DEMAND can be used"
  default     = "ON_DEMAND"
}

variable "eks_node_group_scaling_config" {
  type        = map(number)
  description = "EKS node group auto scaling configuration."
  default = {
    desired_size = 5
    max_size     = 5
    min_size     = 1
  }
}

variable "eks_version" {
  type        = string
  description = "EKS version."
  default     = "1.30"
}

variable "eks_addons" {
  type = list(object({
    name  = string
    version = string
  }))

  default = [
    {
    name  = "kube-proxy"
    version = "v1.30.0-eksbuild.3"
    },
    {
    name  = "vpc-cni"
    version = "v1.18.2-eksbuild.1"
    },
    {
    name  = "coredns"
    version = "v1.11.1-eksbuild.9"
    },
    {
    name  = "aws-ebs-csi-driver"
    version = "v1.30.0-eksbuild.1"
    }
  ]
}

variable eks_master_subnet_ids {
  type        = list(string)
  description = "The VPC's public subnet id which will be used to create the EKS cluster."
}

variable eks_nodes_subnet_ids {
  type        = list(string)
  description = "The VPC's public subnet id which will be used to create the EKS node groups."
}

variable "eks_node_disk_size" {
  type        = number
  description = "EKS nodes disk size"
  default     = 30
}

variable "oidc_thumbprint_list" {
  type        = list(string)
  description = "Additional list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificate(s)"
  default     = []
}

variable "dataset_api_sa_iam_role_name" {
  type        = string
  description = "IAM role name for dataset api service account."
  default     = "dataset-api-sa-iam-role"
}

variable "config_api_sa_iam_role_name" {
  type        = string
  description = "IAM role name for dataset api service account."
  default     = "config-api-sa-iam-role"
}


variable "spark_sa_iam_role_name" {
  type        = string
  description = "IAM role name for dataset api service account."
  default     = "spark-sa-iam-role"
}

variable "spark_namespace" {
  type        = string
  description = "Dataset service namespace."
  default     = "spark"
}

variable "dataset_api_namespace" {
  type        = string
  description = "Dataset service namespace."
  default     = "dataset-api"
}

variable "config_api_namespace" {
  type        = string
  description = "Dataset service namespace."
  default     = "config-api"
}


variable "flink_sa_iam_role_name" {
  type        = string
  description = "IAM role name for flink service account."
  default     = "flink-sa-iam-role"
}

variable "flink_namespace" {
  type        = string
  description = "Flink namespace."
  default     = "flink"
}

variable "druid_raw_sa_iam_role_name" {
  type        = string
  description = "IAM role name for druid raw service account."
  default     = "druid-raw-sa-iam-role"
}

variable "druid_raw_namespace" {
  type        = string
  description = "Druid raw namespace."
  default     = "druid-raw"
}

variable "secor_sa_iam_role_name" {
  type        = string
  description = "IAM role name for secor service account."
  default     = "secor-sa-iam-role"
}

variable "secor_namespace" {
  type        = string
  description = "Secor namespace."
  default     = "secor"
}

variable "s3_exporter_sa_iam_role_name" {
  type        = string
  description = "IAM role name for s3 exporter service account."
  default     = "s3-exporter-sa-iam-role"
}

variable "s3_exporter_namespace" {
  type        = string
  description = "S3 exporter service namespace."
  default     = "s3-exporter"
}

variable "postgresql_backup_sa_iam_role_name" {
  type        = string
  description = "IAM role name for postgresql backup service account."
  default     = "postgresql-backup-sa-iam-role"
}

variable "postgresql_namespace" {
  type        = string
  description = "Postgresql backup namespace."
  default     = "postgresql"
}

variable "redis_backup_sa_iam_role_name" {
  type        = string
  description = "IAM role name for postgresql backup service account."
  default     = "redis-backup-sa-iam-role"
}

variable "redis_namespace" {
  type        = string
  description = "Redis backup namespace."
  default     = "redis"
}

variable "eks_endpoint_private_access" {
   type        = bool
   description = "API server endpoint access"
   default     = false
}
