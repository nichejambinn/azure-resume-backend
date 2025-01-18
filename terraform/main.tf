terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.106.1"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "backend_rg" {
  name     = "resume_backend"
  location = "eastus"
}

resource "azurerm_cosmosdb_account" "resumedb_acc" {
  name                = "resumecosmosdbacc"
  resource_group_name = azurerm_resource_group.backend_rg.name
  location            = azurerm_resource_group.backend_rg.location
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB" # default

  consistency_policy {
    consistency_level = "Session"
  }
  geo_location {
    location          = azurerm_resource_group.backend_rg.location
    failover_priority = 0
  }
  capabilities {
    name = "EnableServerless"
  }
}

resource "azurerm_cosmosdb_sql_database" "resumedb_db" {
  name                = "ResumeDB"
  account_name        = azurerm_cosmosdb_account.resumedb_acc.name
  resource_group_name = azurerm_resource_group.backend_rg.name
}

resource "azurerm_cosmosdb_sql_container" "resumedb_cont" {
  name                = "PageTraffic"
  database_name       = azurerm_cosmosdb_sql_database.resumedb_db.name
  account_name        = azurerm_cosmosdb_account.resumedb_acc.name
  resource_group_name = azurerm_resource_group.backend_rg.name
  partition_key_path  = "/counterId"
  throughput          = 400 # minimum default
}

resource "azurerm_storage_account" "resumeazapp_sa" {
  name                            = "resumeazappstrgacct"
  resource_group_name             = azurerm_resource_group.backend_rg.name
  location                        = azurerm_resource_group.backend_rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
}

resource "azurerm_service_plan" "resumeazapp_asp" {
  name                = "resumeazappasp"
  resource_group_name = azurerm_resource_group.backend_rg.name
  location            = azurerm_resource_group.backend_rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

# resource "azurerm_linux_function_app" "resumeazapp_fnapp" {
#     name = "resumeazapp-ensorcell"
#     resource_group_name = azurerm_resource_group.backend_rg.name
#     location = azurerm_resource_group.backend_rg.location

#     storage_account_name = azurerm_storage_account.resumeazapp_sa
#     storage_account_access_key = azurerm_storage_account.resumeazapp_sa.primary_access_key
#     service_plan_id = azurerm_service_plan.resumeazapp_asp.id

#     https_only = true

#     site_config {

#     }
# }
