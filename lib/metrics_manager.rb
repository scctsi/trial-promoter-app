class MetricsManager
  def self.get_metric_value(message, source, metric_name)
    message.metrics.each do |metric|
      if metric.source == source && !metric.data[metric_name].nil?
        return metric.data[metric_name] 
      else
        return 'N/A'
      end
    end
    
    return 'N/A'
  end
  
  def self.update_metrics(data, source)
    data.each do |key, value|
      if source == :google_analytics
        message = Message.find_by_param(key)
      else
        message = Message.find_by(social_network_id: key)
      end
      message.metrics << Metric.new(source: source, data: value)
      message.save
    end
  end
end
