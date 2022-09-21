provider "helm" {
  kubernetes {
      config_path = "/Users/sada/z/local/one-click/kube_local.yaml"
      config_context = "kind-one-click"
}
}

resource "helm_release" "kafka" {
  name             = "kafka"
#  chart            = "../kafka"
chart              = var.KAFKA_CHART
#  repository       = "/Users/sada/z/azure/infra-terraform-databus-observations/helm_charts"
  namespace        = var.KAFKA_NAMESPACE
  create_namespace = true
  dependency_update = true
#  depends_on       = [postgresql_role.application_role, helm_release.obs_druid_operator]
#  depends_on       = [helm_release.druid_cluster]
  depends_on       = [kind_cluster.one-click]
  wait_for_jobs    = true
  values = [
#"${file("../kafka/values2.yaml")}","${file("../kafka/values.yaml")}"
templatefile("../kafka/values.yaml",
{
#kafka_namespace: "kafka",
kafka_image_repository: "bitnami/kafka"
kafka_image_tag: "2.8.1-debian-10-r31"
kafka_delete_topic_enable: true
kafka_replica_count: 1
# Kubernetes Service type for external access. It can be NodePort or LoadBalancer
service_type: "ClusterIP"
service_port: 9092
# PV config
kafka_persistence_size: "2Gi"
#Zookeeper configs
zookeeper_enabled: true
zookeeper_heapsize: 256
zookeeper_replica_count: 1
}

)

]
}
#provider "kubernetes" {
#  config_path = var.KUBE_CONFIG_PATH
#  config_context = "obsrv-aks"
#}
data "kubernetes_service" "kafka" {
  metadata {
    namespace = "kafka"
    name = "kafka"
  }
depends_on = [kind_cluster.one-click, helm_release.kafka]
}

data "kubernetes_service" "zookeeper" {
  metadata {
    namespace = "kafka"
    name = "kafka-zookeeper"
  }
depends_on = [kind_cluster.one-click, helm_release.kafka]
}
output "kafka-service-ip" {
  value     = data.kubernetes_service.kafka.spec.0.cluster_ip
}

output "zookeeper-service-ip" {
  value     = data.kubernetes_service.zookeeper.spec.0.cluster_ip
}
