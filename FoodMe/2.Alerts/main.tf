# get the New Relic terraform provider
terraform {
  required_version = "~> 1.0"
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "3.6.1"
    }
  }
}

# configure the New Relic provider
provider "newrelic" {
  account_id = (var.nr_account_id)
  api_key    = (var.nr_api_key) # usually prefixed with 'NRAK'
  region     = (var.nr_region)  # Valid regions are US and EU
}

# data source to get information about a specific entity in New Relic that already exists. 
data "newrelic_entity" "app_name" {
  name   = (var.nr_appname) # Note: This must be an exact match of your app name in New Relic (Case sensitive)
  type   = "APPLICATION"
  domain = "APM"
}

# resource to create, update, and delete alerts in New Relic
resource "newrelic_alert_policy" "alert_policy_name" {
  name                = "O11y_asCode-FoodMe-Alerts-TF"
  incident_preference = "PER_CONDITION"
}

# NRQL alert condition - Latency (static)
resource "newrelic_nrql_alert_condition" "GoldenSignals-Latency" {
  policy_id          = newrelic_alert_policy.alert_policy_name.id
  type               = "static"
  name               = "GoldenSignals-Latency"
  description        = "Alert when Latency transactions are taking too long"
  runbook_url        = "https://www.example.com"
  enabled            = true
  aggregation_method = "event_flow"
  aggregation_delay  = 60

  nrql {
    query = "SELECT average(apm.service.overview.web) * 1000 FROM Metric WHERE appName like '%FoodMe%'"
  }

  critical {
    operator              = "above"
    threshold             = 80
    threshold_duration    = 60
    threshold_occurrences = "at_least_once"
  }

  warning {
    operator              = "above"
    threshold             = 40
    threshold_duration    = 60
    threshold_occurrences = "at_least_once"
  }
}

# NRQL alert condition - Errors (static)
resource "newrelic_nrql_alert_condition" "GoldenSignals-Errors" {
  policy_id          = newrelic_alert_policy.alert_policy_name.id
  type               = "static"
  name               = "GoldenSignals-Errors"
  description        = "Alert when Errors are too high"
  runbook_url        = "https://www.example.com"
  enabled            = true
  aggregation_method = "event_flow"
  aggregation_delay  = 60

  nrql {
    query = "SELECT (count(apm.service.error.count) / count(apm.service.transaction.duration))*100 FROM Metric WHERE (appName like '%FoodMe%') AND (transactionType = 'Web')"
  }

  critical {
    operator              = "above"
    threshold             = 2
    threshold_duration    = 60
    threshold_occurrences = "at_least_once"
  }

  warning {
    operator              = "above"
    threshold             = 1
    threshold_duration    = 60
    threshold_occurrences = "at_least_once"
  }
}

# NRQL alert condition - Traffic (baseline)
resource "newrelic_nrql_alert_condition" "GoldenSignals-Traffic" {
  policy_id          = newrelic_alert_policy.alert_policy_name.id
  type               = "baseline"
  name               = "GoldenSignals-Traffic"
  description        = "Alert when Traffic transactions are odd"
  runbook_url        = "https://www.example.com"
  enabled            = true
  aggregation_method = "event_flow"
  aggregation_delay  = 60

  # baseline type only
  baseline_direction = "upper_only"

  nrql {
    query = "SELECT rate(count(apm.service.transaction.duration), 1 minute) FROM Metric WHERE (appName LIKE '%FoodMe%') AND (transactionType = 'Web')"
  }

  critical {
    operator              = "above"
    threshold             = 4
    threshold_duration    = 180
    threshold_occurrences = "at_least_once"
  }

  warning {
    operator              = "above"
    threshold             = 3
    threshold_duration    = 120
    threshold_occurrences = "at_least_once"
  }
}

# NRQL alert condition - Saturation (static)
resource "newrelic_nrql_alert_condition" "GoldenSignals-Saturation" {
  policy_id          = newrelic_alert_policy.alert_policy_name.id
  type               = "static"
  name               = "GoldenSignals-Saturation"
  description        = "Alert when Saturation is high"
  runbook_url        = "https://www.example.com"
  enabled            = true
  aggregation_method = "event_flow"
  aggregation_delay  = 60

  nrql {
    query = "SELECT average(apm.service.memory.physical) * rate(count(apm.service.instance.count), 1 minute) / 1000 FROM Metric WHERE appName LIKE '%FoodMe%'"
  }

  critical {
    operator              = "above"
    threshold             = 20
    threshold_duration    = 60
    threshold_occurrences = "at_least_once"
  }

  warning {
    operator              = "above"
    threshold             = 10
    threshold_duration    = 60
    threshold_occurrences = "at_least_once"
  }
}

resource "newrelic_notification_destination" "alert_email_destination" {
  name = "email-example"
  type = "EMAIL"

  property {
    key   = "email"
    value = var.nr_email
  }
}

resource "newrelic_notification_channel" "alert_notification_email" {
  account_id     = var.nr_account_id
  name           = "email example"
  type           = "EMAIL"
  destination_id = newrelic_notification_destination.alert_email_destination.id
  product        = "IINT"

  property {
    key   = "subject"
    value = "name: {{ alert_notification_email }}"
  }
}



resource "newrelic_workflow" "workflow-example" {
  name                  = "workflow-example"
  account_id            = var.nr_account_id
  muting_rules_handling = "NOTIFY_ALL_ISSUES"
  destinations_enabled  = true
  enabled               = true
  issues_filter {
    name = "Filter-name"
    type = "FILTER"

    predicate {
      attribute = "policyName"
      operator  = "DOES_NOT_CONTAIN"
      values    = ["O11y_asCode-FoodMe-Alerts-TF"]
    }
  }
  destination {
    channel_id = newrelic_notification_channel.alert_notification_email.id
  }
}

