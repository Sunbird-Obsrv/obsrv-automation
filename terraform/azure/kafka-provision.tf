resource "helm_release" "kafka" {
  name             = "kafka"
chart              = var.KAFKA_CHART
  namespace        = var.KAFKA_NAMESPACE
  create_namespace = true
  dependency_update = true
  wait_for_jobs    = true
  values = [
#"${file("../kafka/values2.yaml")}","${file("../kafka/values.yaml")}"
templatefile("../../helm_charts/kafka/values2.yaml",
{
#kafka_namespace: "kafka",
kafka_image_repository: "bitnami/kafka"
kafka_image_tag: "2.8.1-debian-10-r31"
kafka_delete_topic_enable: true
kafka_replica_count: 3
# Kubernetes Service type for external access. It can be NodePort or LoadBalancer
service_type: "LoadBalancer"
service_port: 9092
# PV config
kafka_persistence_size: "50Gi"
#Zookeeper configs
zookeeper_enabled: true
zookeeper_heapsize: 256
zookeeper_replica_count: 3
}

)

]
}
provider "kubernetes" {
  config_path = var.KUBE_CONFIG_PATH
#  config_context = "obsrv-aks"
}
data "kubernetes_service" "kafka" {
  metadata {
    namespace = "kafka"
    name = "kafka-0-external"
  }
depends_on = [azurerm_kubernetes_cluster.aks, helm_release.kafka]
}

data "kubernetes_service" "zookeeper" {
  metadata {
    namespace = "kafka"
    name = "kafka-zookeeper"
  }
depends_on = [azurerm_kubernetes_cluster.aks, helm_release.kafka]
}
output "kafka-service-ip" {
  value     = data.kubernetes_service.kafka.status.0.load_balancer.0.ingress.0.hostname
}

output "zookeeper-service-ip" {
  value     = data.kubernetes_service.zookeeper.spec.0.cluster_ip
}
