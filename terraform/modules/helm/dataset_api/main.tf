resource "helm_release" "docker_registry_secret" {
    name             = "dataset-api-docker-secret"
    chart            = "${path.module}/docker-registry-secret-helm-chart"
    namespace        = var.dataset_api_namespace
    create_namespace = var.dataset_api_create_namespace
    wait_for_jobs    = var.dataset_api_wait_for_jobs
    timeout          = var.dataset_api_install_timeout
    depends_on       = [var.dataset_api_chart_depends_on]
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

resource "helm_release" "dataset_api" {
    name             = var.dataset_api_release_name
    chart            = "${path.module}/${var.dataset_api_chart_path}"
    namespace        = var.dataset_api_namespace
    create_namespace = var.dataset_api_create_namespace
    wait_for_jobs    = var.dataset_api_wait_for_jobs
    timeout          = var.dataset_api_install_timeout
    depends_on       = [var.dataset_api_chart_depends_on]
    force_update     = true
    cleanup_on_fail  = true
    atomic           = true
    values = [
      templatefile("${path.module}/${var.dataset_api_custom_values_yaml}",
        {
          env                                = var.env
          dataset_api_namespace              = var.dataset_api_namespace
          postgresql_obsrv_username          = var.postgresql_obsrv_username
          postgresql_obsrv_user_password     = var.postgresql_obsrv_user_password
          postgresql_obsrv_database          = var.postgresql_obsrv_database
          dataset_api_container_registry     = var.dataset_api_container_registry
          dataset_api_image_name             = var.dataset_api_image_name
          dataset_api_image_tag              = var.dataset_api_image_tag
          dataset_api_sa_annotations         = var.dataset_api_sa_annotations
          denorm_redis_namespace             = var.denorm_redis_namespace
          denorm_redis_release_name          = var.denorm_redis_release_name
          dedup_redis_namespace              = var.dedup_redis_namespace
          dedup_redis_release_name           = var.dedup_redis_release_name
          druid_cluster_release_name         = var.druid_cluster_release_name
          druid_cluster_namespace            = var.druid_cluster_namespace
          command_service_release_name       = var.command_service_release_name
          command_service_namespace          = var.command_service_namespace
          s3_bucket                          = var.s3_bucket
          docker_registry_secret_name        = var.docker_registry_secret_name
          grafana_url                        = var.grafana_url
          encryption_key                     = var.encryption_key
          service_type                       = var.service_type
          s3_region                          = var.s3_region
          storage_provider                   = var.storage_provider     
          enable_lakehouse                   = var.enable_lakehouse
          lakehouse_host                     = var.lakehouse_host
          lakehouse_port                     = var.lakehouse_port
          lakehouse_catalog                  = var.lakehouse_catalog
          lakehouse_schema                   = var.lakehouse_schema
          lakehouse_default_user             = var.lakehouse_default_user     
        }
      )
    ]
}
