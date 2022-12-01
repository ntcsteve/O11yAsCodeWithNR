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

# resource to create, update, and delete dashboards in New Relic
resource "newrelic_one_dashboard" "dashboard_name" {
  name = "O11y_asCode-FoodMe-Dashboards-TF"

  # determines who can see the dashboard in an account
  permissions = "public_read_only"

  page {
    name = "Dashboards as Code"

    widget_markdown {
      title = "Golden Signals - Latency"
      row = 1
      column = 1
      width = 4
      height = 3

      text = "## The Four Golden Signals - Latency\n---\n#### The time it takes to service a request. It’s important to distinguish between the latency of successful requests and the latency of failed requests. \n\n#### For example, an HTTP 500 error triggered due to loss of connection to a database or other critical backend might be served very quickly; however, as an HTTP 500 error indicates a failed request, factoring 500s into your overall latency might result in misleading calculations. \n\n#### On the other hand, a slow error is even worse than a fast error! Therefore, it’s important to track error latency, as opposed to just filtering out errors."
    }

    widget_line {
      title = "Golden Signals - Latency - FoodMe - Line"
      row = 1
      column = 5
      width = 4
      height = 3

      nrql_query {
        query = "SELECT average(apm.service.overview.web) * 1000 as 'Latency' FROM Metric WHERE appName like '%FoodMe%' since 30 minutes ago TIMESERIES AUTO"
      }
    }

    widget_stacked_bar {
      title = "Golden Signals - Latency - FoodMe - Stacked Bar"
      row = 1
      column = 9
      width = 4
      height = 3

      nrql_query {
        query = "SELECT average(apm.service.overview.web) * 1000 as 'Latency' FROM Metric WHERE appName like '%FoodMe%' since 30 minutes ago TIMESERIES AUTO"
      }
    }

    widget_markdown {
      title = "Golden Signals - Errors"
      row = 4
      column = 1
      width = 4
      height = 3

      text = "## The Four Golden Signals - Errors\n---\n\n#### The rate of requests that fail, either explicitly (e.g., HTTP 500s), implicitly (for example, an HTTP 200 success response, but coupled with the wrong content), or by policy (for example, \"If you committed to one-second response times, any request over one second is an error\").\n \n#### Where protocol response codes are insufficient to express all failure conditions, secondary (internal) protocols may be necessary to track partial failure modes. \n\n#### Monitoring these cases can be drastically different: catching HTTP 500s at your load balancer can do a decent job of catching all completely failed requests, while only end-to-end system tests can detect that you’re serving the wrong content."
    }

    widget_area {
      title = "Golden Signals - Errors - FoodMe - Area"
      row = 4
      column = 5
      width = 4
      height = 3

      nrql_query {
        query = "SELECT (count(apm.service.error.count) / count(apm.service.transaction.duration))*100 as 'Errors' FROM Metric WHERE (appName like '%FoodMe%') AND (transactionType = 'Web') SINCE 30 minutes ago TIMESERIES AUTO"
      }
    }

    widget_billboard {
      title = "Golden Signals - Errors - FoodMe - Billboard Compare With"
      row = 4
      column = 9
      width = 4
      height = 3

      nrql_query {
        query = "SELECT (count(apm.service.error.count) / count(apm.service.transaction.duration))*100 as 'Errors' FROM Metric WHERE (appName like '%FoodMe%') AND (transactionType = 'Web') SINCE 30 minutes ago COMPARE WITH 30 minutes ago"
      }
    }

    widget_markdown {
      title = "Golden Signals - Traffic"
      row = 7
      column = 1
      width = 4
      height = 3

      text = "## The Four Golden Signals - Traffic\n---\n\n#### A measure of how much demand is being placed on your system, measured in a high-level system-specific metric. \n\n#### For a web service, this measurement is usually HTTP requests per second, perhaps broken out by the nature of the requests (e.g., static versus dynamic content). \n\n#### For an audio streaming system, this measurement might focus on network I/O rate or concurrent sessions. \n\n#### For a key-value storage system, this measurement might be transactions and retrievals per second."
    }

    widget_table {
      title = "Golden Signals - Traffic - FoodMe - Table"
      row = 7
      column = 5
      width = 4
      height = 3

      nrql_query {
        query = "SELECT rate(count(apm.service.transaction.duration), 1 minute) as 'Traffic' FROM Metric WHERE (appName LIKE '%FoodMe%') AND (transactionType = 'Web') FACET path SINCE 30 minutes ago"
      }
    }

    widget_pie {
      title = "Golden Signals - Traffic - FoodMe - Pie"
      row = 7
      column = 9
      width = 4
      height = 3

      nrql_query {
        query = "SELECT rate(count(apm.service.transaction.duration), 1 minute) as 'Traffic' FROM Metric WHERE (appName LIKE '%FoodMe%') AND (transactionType = 'Web') FACET path SINCE 30 minutes ago"
      }
    }

    widget_markdown {
      title = "Golden Signals - Saturation"
      row = 10
      column = 1
      width = 4
      height = 3

      text = "## The Four Golden Signals - Saturation\n---\n\n#### How \"full\" your service is. A measure of your system fraction, emphasizing the resources that are most constrained (e.g., in a memory-constrained system, show memory; in an I/O-constrained system, show I/O). Note that many systems degrade in performance before they achieve 100% utilization, so having a utilization target is essential.\n\n#### In complex systems, saturation can be supplemented with higher-level load measurement: can your service properly handle double the traffic, handle only 10% more traffic, or handle even less traffic than it currently receives? For very simple services that have no parameters that alter the complexity of the request (e.g., \"Give me a nonce\" or \"I need a globally unique monotonic integer\") that rarely change configuration, a static value from a load test might be adequate. \n\n#### As discussed in the previous paragraph, however, most services need to use indirect signals like CPU utilization or network bandwidth that have a known upper bound. Latency increases are often a leading indicator of saturation. Measuring your 99th percentile response time over some small window (e.g., one minute) can give a very early signal of saturation.\n\n#### Finally, saturation is also concerned with predictions of impending saturation, such as \"It looks like your database will fill its hard drive in 4 hours.\""
    }

    widget_line {
      title = "Golden Signals - Saturation - CPU & Memory - Multi-Queries"
      row = 10
      column = 5
      width = 4
      height = 3

      nrql_query {
        query = "SELECT rate(sum(apm.service.cpu.usertime.utilization), 1 second) * 100 as 'cpuUsed' FROM Metric WHERE appName LIKE '%FoodMe%' SINCE 30 minutes ago TIMESERIES AUTO"
      }

      nrql_query {
        query = "SELECT average(apm.service.memory.physical) * rate(count(apm.service.instance.count), 1 minute) / 1000 as 'memoryUsed %' FROM Metric WHERE appName LIKE '%FoodMe%' SINCE 30 minutes ago TIMESERIES AUTO"
      }
    }

    widget_line {
      title = "Golden Signals - Saturation - Memory - Line Compare With"
      row = 10
      column = 9
      width = 4
      height = 3

      nrql_query {
        query = "SELECT average(apm.service.memory.physical) * rate(count(apm.service.instance.count), 1 minute) / 1000 as 'memoryUsed %' FROM Metric WHERE appName LIKE '%FoodMe%' SINCE 30 minutes ago COMPARE WITH 20 minutes ago TIMESERIES AUTO"
      }
    }
  }
}