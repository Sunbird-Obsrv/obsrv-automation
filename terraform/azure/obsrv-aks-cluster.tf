resource "azurerm_kubernetes_cluster" "aks" {
  name                = "obsrv-kubernetes-cluster"
  location            = "${var.location}" 
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = "obsrvaks"

  default_node_pool {
    name       = "aksnodes"
    node_count = var.NODE_COUNT
    vm_size    = "Standard_B4ms"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "dev"
    cluster_name = "dev"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  sensitive = true
}
output "kube_config" {
  value = "${azurerm_kubernetes_cluster.aks.kube_config_raw}"
   sensitive = true
}


resource "local_file" "kubeconfig" {
  depends_on   = [azurerm_kubernetes_cluster.aks]
  filename     = var.KUBE_CONFIG_FILENAME 
  content      = azurerm_kubernetes_cluster.aks.kube_config_raw
}
