resource "azurerm_resource_group" "rg" {
  name     = "rg-devops-project"
  location = "Central India"
}

# ==========================================
# Azure Container Registry
# ==========================================

resource "azurerm_container_registry" "acr" {
  name                = "pankajacr12345"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku           = "Basic"
  admin_enabled = true
}

# ==========================================
# Azure Kubernetes Service (AKS)
# ==========================================

resource "azurerm_kubernetes_cluster" "aks" {

  name                = "aks-devops-project"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  dns_prefix = "aks-devops-project"


  # ------------------------------------------
  # Default Node Pool
  # ------------------------------------------

  default_node_pool {

    name       = "default"
    node_count = 1

    vm_size = "Standard_B2s"
  }


  # ------------------------------------------
  # Managed Identity
  # ------------------------------------------

  identity {

    type = "SystemAssigned"

  }


  # ------------------------------------------
  # Network Profile
  # ------------------------------------------

  network_profile {

    network_plugin = "azure"

  }

}
# ==========================================
# AKS ACCESS TO ACR
# ==========================================

resource "azurerm_role_assignment" "aks_acr_pull" {

  principal_id = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

  role_definition_name = "AcrPull"

  scope = azurerm_container_registry.acr.id
}