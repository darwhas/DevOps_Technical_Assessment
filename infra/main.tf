terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Variables
variable "location" {
  description = "Azure region where resources will be created"
  default     = "eastus"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  default     = "DevOps_Technical_Assessment"
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg_${var.project_name}_${var.environment}"
  location = var.location
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "asp_${var.project_name}_${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location           = var.location
  os_type            = "Linux"
  sku_name           = "P1v2"
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Web App
resource "azurerm_linux_web_app" "main" {
  name                = "app_${var.project_name}_${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location           = var.location
  service_plan_id    = azurerm_service_plan.main.id

  site_config {
    application_stack {
      docker_image     = "nginx:latest"
      docker_image_tag = "latest"
    }
  }

  app_settings = {
    "WEBSITES_PORT" = "80"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = "st${replace(var.project_name, "_", "")}${var.environment}"
  resource_group_name      = azurerm_resource_group.main.name
  location                = var.location
  account_tier            = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Container Registry
resource "azurerm_container_registry" "main" {
  name                = "acr${replace(var.project_name, "_", "")}${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location           = var.location
  sku                = "Basic"
  admin_enabled      = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "appi_${var.project_name}_${var.environment}"
  location           = var.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
} 