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
