variable "env" {
  type        = string
  description = "Environment name. All resources will be prefixed with this value."
}

variable "setup_sb_datasets_release_name" {
  type        = string
  description = "Submit ingestion helm release name."
  default     = "setup-sb-datasets"
}

variable "setup_sb_datasets_namespace" {
  type        = string
  description = "Submit ingestion namespace."
  default     = "setup-sb-datasets"
}

variable "setup_sb_datasets_chart_path" {
  type        = string
  description = "Submit ingestion chart path."
  default     = "setup-sb-datasets-helm-chart"
}

variable "setup_sb_datasets_chart_install_timeout" {
  type        = number
  description = "Submit ingestion chart install timeout."
  default     = 600
}

variable "setup_sb_datasets_create_namespace" {
  type        = bool
  description = "Create setup_sb_datasets namespace."
  default     = true
}

variable "setup_sb_datasets_wait_for_jobs" {
  type        = bool
  description = "Submit ingestion wait for jobs paramater."
  default     = true
}

variable "setup_sb_datasets_chart_custom_values_yaml" {
  type        = string
  description = "Submit ingestion chart values.yaml path."
  default     = "setup_sb_datasets.yaml.tfpl"
}

variable "setup_sb_datasets_custom_values_yaml" {
  type        = string
  description = "Submit ingestion chart values.yaml path."
  default     = "setup_sb_datasets.yaml.tfpl"
}

variable "setup_sb_datasets_chart_depends_on" {
  type        = any
  description = "List of helm release names that this chart depends on."
  default     = ""
}

variable "druid_cluster_release_name" {
  type        = any
  description = "druid release name"
  default     = "druid-raw"
}

variable "druid_cluster_namespace" {
  type        = any
  description = "druid namespace"
  default     = "druid-raw"
}

variable "kafka_brokers" {
  type        = any
  description = "kafka brokers"
  default     = "kafka-headless.kafka.svc:9092"
}

variable "postgres_host" {
  type        = any
  description = "postgres host name"
  default     = "postgresql-hl.postgresql.svc"
}

variable "postgres_port" {
  type        = any
  description = "postgres port"
  default     = "5432"
}

variable "postgres_user" {
  type        = any
  description = "postgres user name"
  default     = "obsrv"
}

variable "postgres_db" {
  type        = any
  description = "postgres database"
  default     = "obsrv"
}

variable "postgres_paswd" {
  type        = any
  description = "postgres password"
  default     = "obsrv123"
}

variable "setup_sb_datasets_enabled" {
  type        = bool
  description = "Toggle for the activation of a resource during deployment"
  default     = false
}