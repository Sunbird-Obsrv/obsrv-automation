variable "env" {
  type        = string
  description = "Environment name. All resources will be prefixed with this value."
}

variable "building_block" {
  type        = string
  description = "Building block name. All resources will be prefixed with this value."
}
variable "service_type" {
  type = string
  description = "Kubernetes service type either NodePort or LoadBalancer. It is NodePort by default"
}

variable "superset_release_name" {
  type        = string
  description = "Superset helm release name."
  default     = "superset"
}

variable "superset_namespace" {
  type        = string
  description = "Superset namespace."
  default     = "superset"
}

variable "superset_chart_path" {
  type        = string
  description = "Superset helm chart path."
  default     = "superset-helm-chart"
}

variable "superset_create_namespace" {
  type        = bool
  description = "Create superset namespace."
  default     = true
}

variable "superset_wait_for_jobs" {
  type        = bool
  description = "Superset wait for jobs paramater."
  default     = true
}

variable "superset_custom_values_yaml" {
  type        = string
  description = "Superset helm chart values.yaml path."
  default     = "superset.yaml.tfpl"
}

variable "postgresql_admin_username" {
  type        = string
  description = "Postgresql admin username."
}

variable "postgresql_admin_password" {
  type        = string
  description = "Postgresql admin password."
}

variable "postgresql_superset_user_password" {
  type        = string
  description = "Postgresql superset user password."
}

variable "superset_image_tag" {
  type        = string
  description = "Superset image tag."
}

variable "superset_install_timeout" {
  type        = number
  description = "Kafka exporter chart install timeout."
  default     = 1200
}

variable "superset_chart_depends_on" {
  type        = any
  description = "List of helm release names that this chart depends on."
  default     = ""
}

variable "redis_namespace" {
  type        = string
  description = "Namespace of redis installation."
  default     = "redis"
}

variable "redis_release_name" {
  type        = string
  description = "Release name for Redis installation."
  default     = "obsrv-dedup-redis"
}

variable "postgresql_service_name" {
  type        = string
  description = "Service name for Postgres installation."
}

variable "web_console_base_url" {
  type        = string
  description = "Web console base url."
}

variable "superset_base_url" {
  type        = string
  description = "Superset base url."
}

variable "keycloak_base_url" {
  type        = string
  description = "Keycloak base url."
}

variable "redirection_auth_path" {
  type = string
  description = "Either obsrv or keycloak" 
}

variable "oauth_configs" {
  type = map
  description = "Superset config variables. See the below commented code to know values to be passed "
  # default = {
  #   superset_oauth_clientid           =
  #   superset_oauth_client_secret      =
  #   superset_oauth_token              =
  # }
}

variable "dataset_api_namespace" {
  type        = string
  description = "Namespace for dataset api"
}