# Configure terraform
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

# data source to get information about a specific entity in New Relic that already exists. 
data "newrelic_entity" "app_name" {
  name = (var.nr_appname) # Note: This must be an exact match of your app name in New Relic (Case sensitive)
  # type = "APPLICATION"
  # domain = "APM"
}

resource "newrelic_one_dashboard" "tf_dashboard_as_code" {
  name = "O11y_asCode-OpenTelemetry-Dashboards-TF"

  page {
    name = "Dashboards as Code"

    widget_markdown {
      title = "Golden Signals - Latency"
      row    = 1
      column = 1
      width = 4
      height = 3

      text = "## The Four Golden Signals - Latency\n---\n#### The time it takes to service a request. It’s important to distinguish between the latency of successful requests and the latency of failed requests. \n\n#### For example, an HTTP 500 error triggered due to loss of connection to a database or other critical backend might be served very quickly; however, as an HTTP 500 error indicates a failed request, factoring 500s into your overall latency might result in misleading calculations. \n\n#### On the other hand, a slow error is even worse than a fast error! Therefore, it’s important to track error latency, as opposed to just filtering out errors."
    }

    widget_line {
      title = "Golden Signals - Latency - Frontend - Line"
      row = 1
      column = 5
      width = 4
      height = 3

      nrql_query {
        query = "SELECT average(duration.ms) as 'Latency' FROM Span WHERE (entity.name like '%Frontend%') AND ((span.kind LIKE 'server' OR span.kind LIKE 'consumer' OR kind LIKE 'server' OR kind LIKE 'consumer')) SINCE 30 minutes ago TIMESERIES EXTRAPOLATE"
      }
    }

    widget_stacked_bar {
      title = "Golden Signals - Latency - Stacked Bar"
      row = 1
      column = 9
      width = 4
      height = 3

      nrql_query {
        query = "SELECT average(duration.ms) as 'Latency' FROM Span WHERE (entity.name like '%Frontend%') AND ((span.kind LIKE 'server' OR span.kind LIKE 'consumer' OR kind LIKE 'server' OR kind LIKE 'consumer')) SINCE 30 minutes ago TIMESERIES EXTRAPOLATE"
      }
    }

    widget_markdown {
      title = "Golden Signals - Errors"
      row    = 4
      column = 1
      width = 4
      height = 3

      text = "## The Four Golden Signals - Errors\n---\n\n#### The rate of requests that fail, either explicitly (e.g., HTTP 500s), implicitly (for example, an HTTP 200 success response, but coupled with the wrong content), or by policy (for example, \"If you committed to one-second response times, any request over one second is an error\").\n \n#### Where protocol response codes are insufficient to express all failure conditions, secondary (internal) protocols may be necessary to track partial failure modes. \n\n#### Monitoring these cases can be drastically different: catching HTTP 500s at your load balancer can do a decent job of catching all completely failed requests, while only end-to-end system tests can detect that you’re serving the wrong content."
    }

    widget_area {
      title = "Golden Signals - Errors - Frontend - Area"
      row = 4
      column = 5
      width = 4
      height = 3

      nrql_query {
        query = "SELECT (filter(count(*), WHERE otel.status_code = 'ERROR')) / (count(*))*100 as 'Error Rate' FROM Span WHERE (entity.name like '%Frontend%') AND ((span.kind LIKE 'server' OR span.kind LIKE 'consumer' OR kind LIKE 'server' OR kind LIKE 'consumer')) SINCE 30 minutes ago TIMESERIES EXTRAPOLATE"
      }
    }

    widget_billboard {
      title = "Golden Signals - Errors - Frontend - Billboard Compare With"
      row = 4
      column = 9
      width = 4
      height = 3

      nrql_query {
        query = "SELECT (filter(count(*), WHERE otel.status_code = 'ERROR')) / (count(*))*100 as 'Error Rate' FROM Span WHERE (entity.name like '%Frontend%') AND ((span.kind LIKE 'server' OR span.kind LIKE 'consumer' OR kind LIKE 'server' OR kind LIKE 'consumer')) SINCE 30 minutes ago COMPARE WITH 30 minutes ago EXTRAPOLATE"
      }
    }

    widget_markdown {
      title = "Golden Signals - Traffic"
      row    = 7
      column = 1
      width = 4
      height = 3

      text = "## The Four Golden Signals - Traffic\n---\n\n#### A measure of how much demand is being placed on your system, measured in a high-level system-specific metric. \n\n#### For a web service, this measurement is usually HTTP requests per second, perhaps broken out by the nature of the requests (e.g., static versus dynamic content). \n\n#### For an audio streaming system, this measurement might focus on network I/O rate or concurrent sessions. \n\n#### For a key-value storage system, this measurement might be transactions and retrievals per second."
    }

    widget_table {
      title = "Golden Signals - Traffic - Frontend - Table"
      row = 7
      column = 5
      width = 4
      height = 3

      nrql_query {
        query = "SELECT rate(count(*), 1 minute) AS 'Tarffic' FROM Span WHERE (entity.name like '%Frontend%') AND ((span.kind LIKE 'server' OR span.kind LIKE 'consumer' OR kind LIKE 'server' OR kind LIKE 'consumer')) SINCE 30 minutes ago FACET name EXTRAPOLATE"
      }
    }

    widget_pie {
      title = "Golden Signals - Traffic - Frontend - Pie"
      row = 7
      column = 9
      width = 4
      height = 3

      nrql_query {
        query = "SELECT rate(count(*), 1 minute) AS 'Traffic' FROM Span WHERE (entity.name like '%Frontend%') AND ((span.kind LIKE 'server' OR span.kind LIKE 'consumer' OR kind LIKE 'server' OR kind LIKE 'consumer')) SINCE 30 minutes ago FACET name EXTRAPOLATE"
      }
    }

    widget_markdown {
      title = "Golden Signals - Saturation"
      row    = 10
      column = 1
      width = 4
      height = 3

      text = "## The Four Golden Signals - Saturation\n---\n\n#### How \"full\" your service is. A measure of your system fraction, emphasizing the resources that are most constrained (e.g., in a memory-constrained system, show memory; in an I/O-constrained system, show I/O). Note that many systems degrade in performance before they achieve 100% utilization, so having a utilization target is essential.\n\n#### In complex systems, saturation can be supplemented with higher-level load measurement: can your service properly handle double the traffic, handle only 10% more traffic, or handle even less traffic than it currently receives? For very simple services that have no parameters that alter the complexity of the request (e.g., \"Give me a nonce\" or \"I need a globally unique monotonic integer\") that rarely change configuration, a static value from a load test might be adequate. \n\n#### As discussed in the previous paragraph, however, most services need to use indirect signals like CPU utilization or network bandwidth that have a known upper bound. Latency increases are often a leading indicator of saturation. Measuring your 99th percentile response time over some small window (e.g., one minute) can give a very early signal of saturation.\n\n#### Finally, saturation is also concerned with predictions of impending saturation, such as \"It looks like your database will fill its hard drive in 4 hours.\""
    }

    widget_line {
      title = "Golden Signals - Saturation - Node CPU & Memory - Multi-Queries"
      row = 10
      column = 5
      width = 4
      height = 3

      nrql_query {
        query = "SELECT average(1 - system.cpu.utilization) * 100 AS 'Node CPU used %' FROM Metric WHERE entity.name LIKE '%sandbox-vm-opentelemetry%' AND `state` = 'idle' SINCE 30 minutes ago TIMESERIES"
      }

      nrql_query {
        query = "SELECT average(system.memory.utilization) * 100 AS 'Memory used %' FROM Metric WHERE entity.name LIKE '%sandbox-vm-opentelemetry%' AND `state` = 'used' SINCE 30 minutes ago TIMESERIES auto"
      }
    }

    widget_line {
      title = "Golden Signals - Saturation - Node Memory - Line Compare With"
      row = 10
      column = 9
      width = 4
      height = 3

      nrql_query {
        query = "SELECT average(system.memory.utilization) * 100 AS 'Memory used %' FROM Metric WHERE entity.name LIKE '%sandbox-vm-opentelemetry%' AND `state` = 'used' SINCE 30 minutes ago COMPARE WITH 20 minutes ago TIMESERIES auto"
      }
    }
  }
}

# resource to create, update, and delete alerts in New Relic
resource "newrelic_alert_policy" "alert_policy_name" {
  name = "O11y_asCode-OpenTelemetry-Alerts-TF"
}

# NRQL alert condition - Latency (static)
resource "newrelic_nrql_alert_condition" "GoldenSignals-Latency" {
  policy_id                    = newrelic_alert_policy.alert_policy_name.id
  type                         = "static"
  name                         = "GoldenSignals-Latency"
  description                  = "Alert when Latency transactions are taking too long"
  runbook_url                  = "https://www.example.com"
  enabled                      = true
  aggregation_method           = "event_flow"
  aggregation_delay            = 60

  nrql {
    query = "SELECT average(apm.service.overview.web) * 1000 FROM Metric WHERE appName like '%emailservice%'"
  }

  critical {
    operator              = "above"
    threshold             = 10
    threshold_duration    = 60
    threshold_occurrences = "at_least_once"
  }

  warning {
    operator              = "above"
    threshold             = 8
    threshold_duration    = 60
    threshold_occurrences = "at_least_once"
  }
}

# NRQL alert condition - Errors (static)
resource "newrelic_nrql_alert_condition" "GoldenSignals-Errors" {
  policy_id                    = newrelic_alert_policy.alert_policy_name.id
  type                         = "static"
  name                         = "GoldenSignals-Errors"
  description                  = "Alert when Errors are too high"
  runbook_url                  = "https://www.example.com"
  enabled                      = true
  aggregation_method           = "event_flow"
  aggregation_delay            = 60

  nrql {
    query = "SELECT (count(apm.service.error.count) / count(apm.service.transaction.duration))*100 FROM Metric WHERE (appName like '%emailservice%') AND (transactionType = 'Web')"
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
  policy_id                    = newrelic_alert_policy.alert_policy_name.id
  type                         = "baseline"
  name                         = "GoldenSignals-Traffic"
  description                  = "Alert when Traffic transactions are odd"
  runbook_url                  = "https://www.example.com"
  enabled                      = true
  aggregation_method           = "event_flow"
  aggregation_delay            = 60

  # baseline type only
  baseline_direction = "upper_only"

  nrql {
    query = "SELECT rate(count(apm.service.transaction.duration), 1 minute) FROM Metric WHERE (appName LIKE '%emailservice%') AND (transactionType = 'Web')"
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
  policy_id                    = newrelic_alert_policy.alert_policy_name.id
  type                         = "static"
  name                         = "GoldenSignals-Saturation"
  description                  = "Alert when Saturation is high"
  runbook_url                  = "https://www.example.com"
  enabled                      = true
  aggregation_method           = "event_flow"
  aggregation_delay            = 60

  nrql {
    query = "SELECT average(apm.service.memory.physical) * rate(count(apm.service.instance.count), 1 minute) / 1000 FROM Metric WHERE appName LIKE '%emailservice%'"
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

# notification channel
resource "newrelic_alert_channel" "alert_notification_email" {
  name = (var.nr_email)
  type = "email"

  config {
    recipients              = (var.nr_email)
    include_json_attachment = "1"
  }
}

# link the above notification channel to your policy
resource "newrelic_alert_policy_channel" "alert_policy_email" {
  policy_id  = newrelic_alert_policy.alert_policy_name.id
  channel_ids = [
    newrelic_alert_channel.alert_notification_email.id
  ]
}