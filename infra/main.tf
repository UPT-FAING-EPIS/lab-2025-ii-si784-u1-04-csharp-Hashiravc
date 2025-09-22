terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.0"
    }
  }
  required_version = ">= 0.14.9"
}

variable "suscription_id" {
  type        = string
  description = "Azure subscription id"
}

variable "sqladmin_username" {
  type        = string
  description = "Administrator username for server"
}

variable "sqladmin_password" {
  type        = string
  description = "Administrator password for server"
}

provider "azurerm" {
  features {}
  subscription_id = var.suscription_id
}

# Generate a random integer to create a globally unique name
resource "random_integer" "ri" {
  min = 100
  max = 999
}

# Usar Resource Group existente
locals {
  rg_name   = "upt-arg-729"
  rg_region = "westus3"
}

# Create the Linux App Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = "upt-asp-${random_integer.ri.result}"
  location            = local.rg_region
  resource_group_name = local.rg_name
  os_type             = "Linux"
  sku_name            = "F1"
}

# Create the web app
resource "azurerm_linux_web_app" "webapp" {
  name                  = "upt-awa-${random_integer.ri.result}"
  location              = local.rg_region
  resource_group_name   = local.rg_name
  service_plan_id       = azurerm_service_plan.appserviceplan.id
  depends_on            = [azurerm_service_plan.appserviceplan]

  site_config {
    minimum_tls_version = "1.2"
    always_on           = false
    application_stack {
      docker_image_name   = "patrickcuadros/shorten:latest"
      docker_registry_url = "https://index.docker.io"
    }
  }
}

# SQL Server
resource "azurerm_mssql_server" "sqlsrv" {
  name                         = "upt-dbs-${random_integer.ri.result}"
  resource_group_name          = local.rg_name
  location                     = local.rg_region
  version                      = "12.0"
  administrator_login          = var.sqladmin_username
  administrator_login_password = var.sqladmin_password
}

# Firewall rule
resource "azurerm_mssql_firewall_rule" "sqlaccessrule" {
  name             = "PublicAccess"
  server_id        = azurerm_mssql_server.sqlsrv.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

# ⚠️ La base de datos Free está comentada para evitar errores
#resource "azurerm_mssql_database" "sqldb" {
#  name      = "shorten"
#  server_id = azurerm_mssql_server.sqlsrv.id
#  sku_name  = "Free"
#}
