# Configure the Microsoft Azure Provider.
provider "azurerm" {
    version = "=2.0.0"
    features {}

    # Service principal information to login 
    # subscription_id = var.subscription_id  
    # client_id       = var.client_id        
    # client_secret   = var.client_secret    
    # tenant_id       = var.tenant_id      
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
    name     = "RG-TerraNetwork"
    location = var.location
}
