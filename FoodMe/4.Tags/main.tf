# configure Terraform
terraform {
  required_version = "~> 1.0"
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
    }
  }
}

# configure the New Relic provider
provider "newrelic" {
  account_id = (var.nr_account_id)
  api_key = (var.nr_api_key)    # usually prefixed with 'NRAK'
  region = (var.nr_region)      # Valid regions are US and EU
}

# data source to get information about a specific entity in New Relic that already exists. 
data "newrelic_entity" "app_name" {
  name = (var.nr_appname) # Note: This must be an exact match of your app name in New Relic (Case sensitive)
  type = "APPLICATION"
  domain = "APM"
}

# resource to create, update, and delete tags for a New Relic entity.
resource "newrelic_entity_tags" "app_name" {
    guid = data.newrelic_entity.app_name.guid

    tag {
        key = "O11yAsCode"
        values = ["Hashicorp", "Terraform", "HCL"]
    }

    tag {
        key = "Workloads"
        values = ["FoodMe"]
    }
}
