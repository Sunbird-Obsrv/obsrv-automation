resource "helm_release" "setup_sb_datasets" {
    count            = var.setup_sb_datasets_enabled ? 1 : 0
    name             = var.setup_sb_datasets_release_name
    chart            = "${path.module}/${var.setup_sb_datasets_chart_path}"
    namespace        = var.setup_sb_datasets_namespace
    create_namespace = var.setup_sb_datasets_create_namespace
    depends_on       = [var.setup_sb_datasets_chart_depends_on]
    wait_for_jobs    = var.setup_sb_datasets_wait_for_jobs
    timeout          = var.setup_sb_datasets_chart_install_timeout
    force_update     = true
    cleanup_on_fail  = true
    atomic           = true
    values = [
      templatefile("${path.module}/${var.setup_sb_datasets_custom_values_yaml}",
        {
           env                         = var.env
           setup_sb_datasets_namespace = var.setup_sb_datasets_namespace
           druid_cluster_namespace     = var.druid_cluster_namespace
           druid_cluster_release_name  = var.druid_cluster_release_name
           kafka_brokers               = var.kafka_brokers
           postgres_host               = var.postgres_host
           postgres_port               = var.postgres_port
           postgres_db                 = var.postgres_db
           postgres_paswd              = var.postgres_paswd
           postgres_user               = var.postgres_user
        }
      )
    ]
}