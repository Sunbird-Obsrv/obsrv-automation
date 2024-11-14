resource "helm_release" "docker_registry_secret" {
    name             = "flink-docker-secret"
    chart            = "${path.module}/docker-registry-secret-helm-chart"
    namespace        = var.flink_namespace
    create_namespace = var.flink_create_namespace
    depends_on       = [var.flink_chart_depends_on,helm_release.flink_sa]
    wait_for_jobs    = var.flink_wait_for_jobs
    timeout          = var.flink_chart_install_timeout
    force_update     = true
    cleanup_on_fail  = true
    atomic           = true
    values = [
    templatefile("${path.module}/docker_registry_secrets.yaml.tfpl",
    {
        docker_registry_secret_dockerconfigjson     = var.docker_registry_secret_dockerconfigjson,
        docker_registry_secret_name                 = var.docker_registry_secret_name
    })
  ]
}

resource "helm_release" "flink_sa" {
  name             = "${var.flink_sa_release_name}-sa"
  chart            = "${path.module}/${var.flink_chart_path_sa}"
  namespace        = var.flink_namespace
  create_namespace = var.flink_create_namespace
  wait_for_jobs    = var.flink_wait_for_jobs
  timeout          = var.flink_chart_install_timeout
  force_update     = true
  cleanup_on_fail  = true
  atomic           = true
  values = [
    templatefile("${path.module}/${var.flink_custom_values_yaml_sa}",
      {
        flink_namespace            = var.flink_namespace
        flink_sa_annotations       = var.flink_sa_annotations
        flink_service_account_name = "${var.flink_namespace}-sa"
      }
    )
  ]
}

resource "helm_release" "flink" {
    for_each         = contains([var.unified_pipeline_enabled], true ) ? var.flink_unified_pipeline_release_names : var.flink_release_names
    name             = each.key
    chart            = "${path.module}/${var.flink_chart_path}"
    namespace        = var.flink_namespace
    create_namespace = var.flink_create_namespace
    depends_on       = [var.flink_chart_depends_on,helm_release.flink_sa]
    wait_for_jobs    = var.flink_wait_for_jobs
    timeout          = var.flink_chart_install_timeout
    force_update     = true
    cleanup_on_fail  = true
    atomic           = true
    values = [
      templatefile("${path.module}/${var.flink_custom_values_yaml}",
      {
          env                            = var.env
          flink_image_name               = each.value
          flink_namespace                = var.flink_namespace
          flink_container_registry       = "${var.flink_container_registry}"
          flink_image_tag                = var.flink_image_tag
          checkpoint_store_type          = var.flink_checkpoint_store_type
          s3_access_key                  = var.s3_access_key
          s3_secret_key                  = var.s3_secret_key
          azure_account                  = var.azure_storage_account_name
          azure_secret                   = var.azure_storage_account_key
          postgresql_service_name        = var.postgresql_service_name
          postgresql_obsrv_username      = var.postgresql_obsrv_username
          postgresql_obsrv_user_password = var.postgresql_obsrv_user_password
          postgresql_obsrv_database      = var.postgresql_obsrv_database
          checkpoint_base_url            = var.checkpoint_base_url
          denorm_redis_namespace         = var.denorm_redis_namespace
          denorm_redis_release_name      = var.denorm_redis_release_name
          dedup_redis_namespace          = var.dedup_redis_namespace
          dedup_redis_release_name       = var.dedup_redis_release_name
          docker_registry_secret_name    = var.docker_registry_secret_name
      })
    ]
}
