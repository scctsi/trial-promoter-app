class MetricManager
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
