provider "helm" {
  kubernetes {
    config_path = var.KUBE_CONFIG_PATH
    config_context = "obsrv-aks"  
}
}

#provider "kubernetes" {
#  config_path = var.KUBE_CONFIG_PATH
#  config_context = "obsrv-aks"
#}

resource "helm_release" "obs_druid_cluster" {
  name             = "druid-cluster"
  chart            = var.DRUID_CLUSTER_CHART
  namespace        = var.DRUID_NAMESPACE
  create_namespace = true
  depends_on       = [helm_release.obs_druid_operator,azurerm_kubernetes_cluster.aks]
  wait_for_jobs    = true
  
  values = [
    templatefile("../../helm_charts/druid-cluster/values.yaml",
      {
        end_point  = azurerm_postgresql_server.postgres.fqdn,
        druid_namespace = var.DRUID_NAMESPACE
        druid_user      = "druid@postgresql-server-obsrv" 
        druid_password  = azurerm_postgresql_server.postgres.administrator_login_password
        azure_storage_container = var.DRUID_DEEP_STORAGE_CONTAINER
        deployment_stage = var.STAGE
        druid_worker_capacity = var.DRUID_MIDDLE_MANAGER_WORKER_NODES
        azure_storage_account = var.STORAGE_ACCOUNT
        azure_storage_key = azurerm_storage_account.obsrv-sa.primary_access_key 
      }
    )
  ]
}
data "kubernetes_service" "druid" {
  metadata {
    namespace = "druid-raw"
    name = "druid-cluster-zookeeper"
  }
depends_on       = [helm_release.obs_druid_cluster]
}
resource "helm_release" "obs_druid_operator" {
  name             = "druid-operator"
  chart            =  var.DRUID_OPERATOR_CHART
  create_namespace = true
  namespace        = var.DRUID_NAMESPACE
  wait_for_jobs    = true
}


