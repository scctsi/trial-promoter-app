class MetricsManager
  def self.get_metric_value(message, source, metric_name)
    message.metrics.each do |metric|
      return metric.data[metric_name] if metric.source == source && !metric.data[metric_name].nil?
    end

    return 'N/A'
  end

  def self.update_metrics(data, source, klass = Message)
    if klass == Post
      data.each do |key, value|
        post = Post.find_by_param(key)
        if !(post.nil?)
          metrics = post.metrics.select{ |metric| metric.source == source }
          if metrics.count > 0
            metrics[0].data = value
            metrics[0].save
          else
            post.metrics << Metric.new(source: source, data: value)
            post.save
          end
        end
      end
    else
      data.each do |key, value|
        if source == :google_analytics
          message = Message.find_by_param(key)
        else
          message = Message.find_by_alternative_identifier(key)
        end
        if !(message.nil?)
          metrics = message.metrics.select{ |metric| metric.source == source }
          if metrics.count > 0
            metrics[0].data = value
            metrics[0].save
          else
            message.metrics << Metric.new(source: source, data: value)
            message.save
          end
        end
      end
    end
  end
  
  def self.update_impressions_by_day(date, data)
    data.each do |key, value|
      message = Message.find_by_alternative_identifier(key)
      if !(message.nil?)
        message.impressions_by_day[date] = value
        message.save
      end
    end
  end
end
