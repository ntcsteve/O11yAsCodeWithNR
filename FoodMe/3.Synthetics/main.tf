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

# resource to create, update, and delete a synthetics monitor in New Relic.
resource "newrelic_synthetics_monitor" "O11y_asCode-SimpleBrowser-TF" {
  name = "O11y_asCode-SimpleBrowser-TF"
  type = "BROWSER"

  # The interval (in minutes) at which this monitor should run.
  frequency = 5
  status = "ENABLED"

  # Public minion location
  # https://docs.newrelic.com/docs/synthetics/synthetic-monitoring/administration/synthetic-public-minion-ips/#location
  locations = ["AWS_AP_SOUTHEAST_2", "AWS_AP_SOUTHEAST_1", "AWS_AP_SOUTH_1", "AWS_AP_NORTHEAST_1", "AWS_AP_NORTHEAST_2"]

  uri                       = (var.nr_uri)
  # validation_string       = "add example validation check here" # optional for type "SIMPLE" and "BROWSER"
  # verify_ssl              = true                                # optional for type "SIMPLE" and "BROWSER"
  # bypass_head_request     = true                                # Note: optional for type "BROWSER" only                        
}