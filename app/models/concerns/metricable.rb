module Metricable
  def self.get_metric(message, platform, metric)
    p platform
     MetricsManager.get_metric_value(message, platform, metric)  == 'N/A' ? 'NDA' : MetricsManager.get_metric_value(message, platform, metric)
    # if platform == metric.source
    #   return 'NDA'
    # else
    #   return 'N/A'
    # end
  end
end