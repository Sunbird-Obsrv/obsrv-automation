variable "env" {
  type        = string
  description = "Environment name. All resources will be prefixed with this value."
}

variable "building_block" {
  type        = string
  description = "Building block name. All resources will be prefixed with this value."
}

variable "secor_release_name" {
  type        = string
  description = "Secor helm release name."
  default     = "secor"
}

variable "secor_image_tag" {
  type        = string
  description = "secor image version"
}

variable "jobs" {
  description = "Create release names"
  type        = list(string)
  default = [
    "ingest-backup", "failed-backup", "transform-backup",
    # "raw-backup", "unique-backup", "denorm-backup",
    "system-events", "system-telemetry-events",
    "masterdata-ingest-backup", "masterdata-transform-backup", "masterdata-failed-backup"
  ]
}

variable "secor_image_repository" {
  type        = string
  description = "secor image version"
  default     = "sanketikahub/secor"
}

variable "secor_namespace" {
  type        = string
  description = "Secor namespace."
}

variable "secor_chart_path" {
  type        = string
  description = "Secor chart path."
  default     = "secor-helm-chart"
}

variable "secor_chart_install_timeout" {
  type        = number
  description = "Secor chart install timeout."
  default     = 3000
}

variable "secor_create_namespace" {
  type        = bool
  description = "Create secor namespace."
  default     = true
}

variable "secor_wait_for_jobs" {
  type        = bool
  description = "Secor wait for jobs paramater."
  default     = true
}

variable "secor_chart_dependecy_update" {
  type        = bool
  description = "Kafka chart dependency update."
  default     = true
}


variable "secor_threads_count" {
  type        = number
  description = "Secor process number of threads."
  default     = 2
}

variable "secor_extractor_timestamp_key" {
  type        = string
  description = "Secor process number of threads."
  default     = "syncts"
}

variable "secor_default_timestamp_key" {
  type        = string
  description = "Secor process number of threads."
  default     = "obsrv_meta.syncts"
}

variable "secor_cpu_request" {
  type        = string
  description = "Secor CPU Request"
  default     = "128m"
}

variable "secor_memory_request" {
  type        = string
  description = "Secor Memory Request"
  default     = "512Mi"
}

variable "secor_cpu_limit" {
  type        = string
  description = "Secor CPU limit"
  default     = "128m"
}

variable "secor_memory_limit" {
  type        = string
  description = "Secor Memory limit"
  default     = "512Mi"
}

variable "secor_backup_interval" {
  type        = number
  description = "Secor backup interval"
  default     = 1000 # In seconds
}

variable "secor_backup_max_file_size" {
  type        = number
  description = "Secor backup max file size"
  default     = 100000000 # In bytes
}

variable "secor_backup_basepath" {
  type        = string
  description = "Secor backup base path"
  default     = "telemetry-data"
}

variable "secor_backup_pv_size" {
  type        = string
  description = "secor backup pv size"
  default     = "1Gi"
}

variable "jvm_memory" {
  type        = string
  description = "secor process JVM memory"
  default     = "1024m"
}



variable "kafka_broker_ip" {
  type        = string
  description = "Kafka broker address"
  default     = "kafka-headless.kafka.svc.cluster.local"
}

variable "kafka_zookeeper_ip" {
  type        = string
  description = "Kafka zookeeper address"
  default     = "kafka-zookeeper-headless.kafka.svc.cluster.local:2181"
}

variable "cloud_store_provider" {
  type        = string
  description = "Cloud storage provider"
  default     = "S3" # Can be one of S3, GS, Swift or Azure
}

variable "upload_manager" {
  type        = string
  description = "Upload manager Class"
  default     = "com.pinterest.secor.uploader.S3UploadManager"
}

variable "cloud_storage_bucket" {
  type        = string
  description = "Cloud storage bucket"
  default     = "telemetry-data-store"
}

variable "secor_custom_values_yaml" {
  type    = string
  default = "secor.yaml.tfpl"
}

variable "secor_chart_depends_on" {
  type        = any
  description = "List of helm release names that this chart depends on."
  default     = ""
}

# Temporary variable since secor chart is not generlized yet
variable "region" {
  type        = string
  description = "AWS region to create the resources."
}

variable "kubernetes_storage_class" {
  type        = string
  description = "Storage Class"
}
variable "timezone" {
  type        = string
  description = "Timezone property to backup the data"
}

variable "image_pull_policy" {
  type        = string
  description = "Docker image pull policy"
  default     = "IfNotPresent"
}

variable "fallback_timestamp_key" {
  type        = string
  description = "default timestamp key"
  default     = ""
}

variable "secor_sa_annotations" {
  type        = string
  description = "Service account annotations for secor service account."
  default     = "serviceAccountName: default"
}
