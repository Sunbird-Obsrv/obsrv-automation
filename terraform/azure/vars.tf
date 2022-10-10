variable "location" {
default = "centralindia"
}
variable "RESOURCE_GROUP" {
default = "Obsrv-testing"
}

variable "NODE_COUNT"{
default = 4
}

variable "KUBE_CONFIG_FILENAME" {
  description = "Druid Instance Running Namespace"
  default     = "../aks.yaml"
}

variable "DRUID_NAMESPACE" {
  description = "Druid Instance Running Namespace"
  default     = "druid-raw"
}

variable "FLINK_NAMESPACE" {
  description = "Druid Instance Running Namespace"
  default     = "flink-obsrv"
}

variable "DRUID_CLUSTER_CHART" {
  description = "Druid Instance Running Namespace"
  default     = "../../helm_charts/druid-cluster"
}

variable "DRUID_CLUSTER_VALUES" {
default = "../../helm_charts/druid-cluster/values.yaml"
}

variable "DRUID_OPERATOR_VALUES"{
default = "../../helm_charts/druid-operator/values.yaml"
}

variable "FLINK_CHART" {
  description = "Flink chart"
  default     = "../pipeline_jobs"
}

variable "DRUID_OPERATOR_CHART" {
  description = "Druid Instance Running Namespace"
  default     = "../../helm_charts/druid-operator"
}

variable "NAME_TELEMETRY_EVENTS"{
  description = "Name of sample telemetry events"
  default     = "2020-06-04-1591233567703.json.gz"
}

variable "PATH_TELEMETRY_EVENTS"{
description = "Path of sample telemetry events"
  default     = "../../../2020-06-04-1591233567703.json.gz"
}

variable "KAFKA_CHART" {
  description = "Kafka Instance Running Namespace"
  default     = "../../helm_charts/kafka"
}

variable "POSTGRES_ADMIN_NAME" {
default = "druid"
}

variable "POSTGRES_ADMIN_PASSWORD" {
default = "SANK@2022"
}
variable "STORAGE_ACCOUNT" {
  description = "Deployment Stage"
  default     = "obsrv-storage-acc"
}


variable "KUBE_CONFIG_PATH" {
  description = "Path of the kubeconfig file"
  type        = string
  default     = "../aks.yaml"
}

variable "DRUID_RDS_DB_NAME" {
  description = "DB name of Druid postgress"
  type        = string
  default     = "druid_raw"
}

variable "RDS_INSTANCE_TYPE" {
  description = "Postgres Instance Type"
  type        = string
  default     = "db.t3.micro"
}
// Currently used only in the AWS_DB_INSTANCE Resource
variable "APPLY_IMMEDIATELY" {
  type = bool
  description = "Apply changes immediately"
  default = true
}

variable "RDS_PASSWORD" {
  description = "Password of RDS DB"
  type        = string
  default     = "SanK@2022"
}

variable "RDS_USER" {
  description = "Password of RDS DB"
  type        = string
  default = "postgres"
}

variable "DRUID_RDS_USER" {
  description = "User of Druid postgress"
  type        = string
  default     = "druid"
}

variable "RDS_DRUID_USER_PASSWORD" {
  description = "User of Druid postgress"
  type        = string
  default     = "SanK@2022"
}

variable "DRUID_DEEP_STORAGE_CONTAINER" {
  type    = string
  default = "obsrv-blob"
}

variable "RDS_STORAGE" {
  type    = number
  default = 5120
}

variable "DRUID_MIDDLE_MANAGER_WORKER_NODES" {
  type    = number
  default = 2
}
variable "DRUID_MIDDLE_MANAGER_PEON_HEAP" {
  type    = string
  default = "256M"
}
variable "SUPERSET_NAMESPACE" {
  type    = string
  default = "superset"
}

variable "SUPERSET_RDS_DB_NAME" {
  type    = string
  default = "superset"
}
variable "SUPERSET_RDS_DB_USER" {
  type    = string
  default = "superset"
}

variable "SUPERSET_RDS_DB_PASSWORD" {
  type    = string
  default = "SanK@2022"
}

variable "SUPERSET_ADMIN_USERNAME" {
  type    = string
  default = "admin"
}
variable "SUPERSET_ADMIN_FIRSTNAME" {
  type    = string
  default = "Superset"
}

variable "SUPERSET_ADMIN_LASTNAME" {
  type    = string
  default = "Admin"
}

variable "SUPERSET_ADMIN_PASSWORD" {
  type    = string
default   = "admin123"
}
variable "SUPERSET_ADMIN_EMAIL" {
  type    = string
  default = "admin@superset.com"
}
variable "SUPERSET_RDS_PORT" {
  type    = string
  default = "5432"
}
variable "KAFKA_NAMESPACE" {
  description = "KAFKA Instance Running Namespace"
  default     = "kafka"
}

variable "KAFKA_VALUES_PATH"{
  default = "../../helm_charts/kafka/values.yaml"
}

variable "SUPERSET_VALUES_PATH"{
  default = "../../helm_charts/superset-helm/values.yaml"
}
