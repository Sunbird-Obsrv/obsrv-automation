variable "env" {
  type        = string
  description = "Environment name. All resources will be prefixed with this value."
}

variable "building_block" {
  type        = string
  description = "Building block name. All resources will be prefixed with this value."
}

variable "dataset_api_release_name" {
  type        = string
  description = "Dataset service helm release name."
  default     = "dataset-api"
}

variable "dataset_api_namespace" {
  type        = string
  description = "Dataset service namespace."
}

variable "dataset_api_chart_path" {
  type        = string
  description = "Dataset service chart path."
  default     = "dataset-api-helm-chart"
}

variable "dataset_api_create_namespace" {
  type        = bool
  description = "Create Dataset service namespace."
  default     = true
}

variable "dataset_api_custom_values_yaml" {
  type = string
  default = "dataset_api.yaml.tfpl"
}

variable "dataset_api_wait_for_jobs" {
  type        = bool
  description = "Dataset service wait for jobs paramater."
  default     = true
}

variable "dataset_api_install_timeout" {
  type        = number
  description = "Dataset service chart install timeout."
  default     = 1200
}

variable "postgresql_obsrv_database" {
  type        = string
  description = "obsrv postgres database"
}

variable "postgresql_obsrv_username" {
  type = string
  description = "obsrv postgres username"
  default = "obsrv"
}

variable "postgresql_obsrv_user_password" {
  type = string
  description = "obsrv user postgres password"
}

variable "dataset_api_chart_depends_on" {
  type        = any
  description = "List of helm release names that this chart depends on."
  default     = ""
}

variable "dataset_api_container_registry" {
  type        = string
  description = "Container registry. For example docker.io/obsrv"
  default     = "sunbird"
}

variable "dataset_api_image_name" {
  type        = string
  description = "Dataset api image name."
  default     = "sb-obsrv-api-service"
}

variable "dataset_api_image_tag" {
  type        = string
  description = "Dataset api image tag."
  default     = "1.0.0-GA"
}

variable "dataset_api_sa_annotations" {
  type        = string
  description = "Service account annotations for dataset api service account."
  default     = "serviceAccountName: default"
}

variable "denorm_redis_namespace" {
  type        = string
  description = "Namespace of Redis installation."
  default     = "redis"
}

variable "denorm_redis_release_name" {
  type        = string
  description = "Release name for Redis installation."
  default     = "obsrv-denorm-redis"
}

variable "dedup_redis_release_name" {
  type        = string
  description = "Redis helm release name."
  default     = "obsrv-dedup-redis"
}

variable "dedup_redis_namespace" {
  type        = string
  description = "Redis namespace."
  default     = "redis"
}

variable "s3_bucket" {
  type        = string
  description = "S3 bucket name for dataset api exhaust."
  default     = ""
}