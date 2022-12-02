# get the New Relic terraform provider
terraform {
  required_version = "~> 1.0"
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
    }
  }
}

# Configure the New Relic provider
provider "newrelic" {
  account_id = (var.nr_account_id)
  api_key = (var.nr_api_key)    # usually prefixed with 'NRAK'
  region = (var.nr_region)      # Valid regions are US and EU
}

# resource to create, update, and delete a New Relic workload.
resource "newrelic_workload" "O11y_asCode-Workloads-TF" {
    name = "O11y_asCode-Workloads-TF"
    account_id = (var.nr_account_id)

    # Include entities with a set of tags.
    entity_search_query {
        query = "tags.Workloads='FoodMe'"
    }
}