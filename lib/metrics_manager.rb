class MetricsManager
  def self.get_metric_value(message, source, metric_name)
    message.metrics.each do |metric|
<<<<<<< HEAD:lib/metrics_manager.rb
      return metric.data[metric_name] if metric.source == source && !metric.data[metric_name].nil?
=======
      if metric.source == source && !metric.data[metric_name].nil?
        return metric.data[metric_name] 
      else
        return 'N/A'
      end
>>>>>>> b99a0d13e58cfe1a695fece277dc7d49528382b2:lib/metrics_manager.rb
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
