# get the New Relic terraform provider
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
  # The human-readable identifier for the monitor.
  name = "O11y_asCode-SimpleBrowser-TF"
  # The monitor type. Valid values are SIMPLE and BROWSER.
  type = "BROWSER"

  # The interval (in minutes) at which this monitor should run.
  period = "EVERY_30_MINUTES"
  # The run state of the monitor.	
  status = "ENABLED"

  # Public minion location
  # https://docs.newrelic.com/docs/synthetics/synthetic-monitoring/administration/synthetic-public-minion-ips/#location
  locations_public = ["AP_SOUTHEAST_2", "AP_SOUTHEAST_1", "AP_SOUTH_1", "AP_NORTHEAST_1", "AP_NORTHEAST_2"]
	
  # The URI the monitor runs against.
  uri = (var.nr_url)                      
}