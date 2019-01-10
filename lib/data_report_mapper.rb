class DataReportMapper
  attr_accessor :experiment
  
  def initialize(experiment)
    self.experiment = experiment
  end
  
  def database_id(message)
    return message.id
  end
  
  def social_network_id(message)
    return "SNI: #{message.social_network_id}"
  end

  def campaign_id(message)
    return "CI: #{message.campaign_id}"
  end

  def backdated(message)
    return "Yes" if message.backdated
    return "No"
  end
  
  def note(message)
    return message.note
  end
  
  def experiment_variable(message, variable_name, value_mapping = nil)
    # A value mapping maps the actual value of an experiment variable to a numerical value, usually used for statistical analysis
    return value_mapping[message.message_template.experiment_variables['theme']] if value_mapping != nil
    return message.message_template.experiment_variables[variable_name]
  end

  def variant(message)
    return message.message_template.content.chomp("{url}")
  end

  def sm_type(message, platform_mapping = {:twitter => 'T', :facebook => 'F', :instagram => 'I'})
    return platform_mapping[message.platform]
  end

  def day_experiment(message)
    # Ordinal day of the experiment: 1 for first day of experiment, 2 for second day of experiment etc
    return (message.scheduled_date_time.to_i - experiment.message_distribution_start_date.to_i) / 1.day.seconds + 1
  end

  def date_sent(message)
    return message.scheduled_date_time.strftime("%Y-%m-%d")
  end

  # Ruby maps Sunday as 0, so mapper follows data dictionary
  def day_sent(message, day_of_week_mapper = {'Sunday' => '7', 'Monday' => '1', 'Tuesday' => '2', 'Wednesday' => '3', 'Thursday' => '4', 'Friday' => '5', 'Saturday' => '6'})
    return day_of_week_mapper[message.scheduled_date_time.strftime("%A")]
  end

  def time_sent(message) 
    if message.medium == :ad
      return 'NDA'
    elsif message.buffer_update.sent_from_date_time.nil?
      return 'NDA'
    else  
      return message.buffer_update.sent_from_date_time.strftime("%H:%M:%S")
    end
  end

  def medium(message, medium_mapping = {:organic => '1', :ad => '2'})
    return medium_mapping[message.medium]
  end

  def image_included(message, image_mapping = {'without' => '0', 'with' => '1'})
    return image_mapping[message.image_present]
  end

  def clicks_for_day(message, day_offset = 0)
    return message.click_meter_tracking_link.clicks.select{|click| click.click_time.to_date == (message.scheduled_date_time.to_date + day_offset.day)}
  end 
  
  def clicks_for_experiment(message)
    return message.click_meter_tracking_link.clicks.map
  end

  def click_times(clicks, human = true, unique = true, timezone = "America/Los_Angeles")  
    return clicks.map{|click| click.click_time.in_time_zone(timezone).strftime("%H:%M:%S") if (click.human? == human && click.unique? == unique) }.compact
  end

  def impressions_for_day(message, offset)
    if message.impressions_by_day[(message.scheduled_date_time + offset.day).to_date].nil?
      return 'NDA'
    else
      impressions_total = message.impressions_by_day[(message.scheduled_date_time + offset.day).to_date] 
      if (offset > 0 && message.medium == :organic)
        earlier_offset = offset - 1
        if (message.impressions_by_day[(message.scheduled_date_time + (earlier_offset).day).to_date] != nil)
            impressions_total -= message.impressions_by_day[(message.scheduled_date_time + earlier_offset.day).to_date] 
        end
      end
      return impressions_total 
    end
  end

  def impressions_for_experiment(message)
    return get_metric(message, message.platform, 'impressions')
  end

  def retweets_twitter(message)
    return get_metric(message, :twitter, 'retweets')
  end

  def shares_facebook(message)
    return get_metric(message, :facebook, 'shares')
  end

  def shares_instagram(message)
    # Our code has a logic issue where we require a metric_alias when getting Instagram metrics, so we need to just pass in any value for the metric_alias
    return get_metric(message, :instagram, 'shares', 'shares')
  end

  def replies_twitter(message)
    return get_metric(message, :twitter, 'replies')
  end

  def comments_facebook(message)
    return get_metric(message, :facebook, 'comments')
  end

  def comments_instagram(message)
    # Our code has a logic issue where we require a metric_alias when getting Instagram metrics, so we need to just pass in any value for the metric_alias
    return get_metric(message, :instagram, 'comments', 'comments')
  end

  def likes_twitter(message)
    return get_metric(message, :twitter, 'likes')
  end

  def reactions_facebook(message)
    return get_metric(message, :facebook, 'reactions', 'likes')
  end

  def reactions_instagram(message)
    return get_metric(message, :instagram, 'reactions', 'likes')
  end

  def sessions_for_day(message, offset = 0, ip_exclusion_list)
    scheduled_start_of_day = (message.scheduled_date_time + offset.day)
    scheduled_end_of_day = scheduled_start_of_day.end_of_day
    
    return message.get_sessions(scheduled_start_of_day, scheduled_end_of_day, ip_exclusion_list).count
  end

  def sessions_for_experiment(message, ip_exclusion_list)
    return message.get_sessions(DateTime.new(1970, 1, 1), DateTime.new(2100, 1, 1), ip_exclusion_list).count
  end
  
  def total_website_clicks_day(message, offset = 0)
    return calculate_goal_count(message, message.scheduled_date_time + offset.day)
  end

  def total_website_clicks_experiment(message, ip_exclusion_list)
    sessions = message.get_sessions(DateTime.new(1970, 1, 1), DateTime.new(2100, 1, 1), ip_exclusion_list)
    return message.get_goal_count(sessions)
  end

  def users(message)
    return MetricsManager.get_metric_value(message, :google_analytics, 'ga:users') == 'N/A' ? 'NDA' : MetricsManager.get_metric_value(message, :google_analytics, 'ga:users')
  end

  def exits(message)
    return MetricsManager.get_metric_value(message, :google_analytics, 'ga:exits') == 'N/A' ? 'NDA' : MetricsManager.get_metric_value(message, :google_analytics, 'ga:exits')
  end

  def session_duration(message)
    return MetricsManager.get_metric_value(message, :google_analytics, 'ga:sessionDuration') == 'N/A' ? 'NDA' : MetricsManager.get_metric_value(message, :google_analytics, 'ga:sessionDuration')
  end

  def time_on_page(message)
    return MetricsManager.get_metric_value(message, :google_analytics, 'ga:timeOnPage')  == 'N/A' ? 'NDA' : MetricsManager.get_metric_value(message, :google_analytics, 'ga:timeOnPage')
  end

  def pageviews(message)
    return MetricsManager.get_metric_value(message, :google_analytics, 'ga:pageviews') == 'N/A' ? 'NDA' : MetricsManager.get_metric_value(message, :google_analytics, 'ga:pageviews')
  end

  private
  def calculate_goal_count(message, date)
    sessions = message.get_sessions(date.beginning_of_day, date.end_of_day, experiment.ip_exclusion_list)
    return message.get_goal_count(sessions) 
  end
  
  def get_metric(message, source_platform, metric, metric_alias = nil)
    # The data report always returns ALL columns for every message. This includes for example likes_twitter even for Facebook and Insagram messages.
    # So if we ask a message whose platform is Facebook to get likes from Twitter (source_platform), we need to return Not Applicable (N/A).
    return 'N/A' if message.platform != source_platform 
    
    # Instagram metrics are provided by Facebook, so we always convert the source_platform to facebook when the source_platform is Instagram
    source_platform = :facebook if source_platform == :instagram

    if metric_alias.nil? 
      return MetricsManager.get_metric_value(message, source_platform, metric)  == 'N/A' ? 'NDA' : MetricsManager.get_metric_value(message, source_platform, metric)
    else
      metric_value = MetricsManager.get_metric_value(message, source_platform, metric)
      if metric_value == 'N/A'
        return MetricsManager.get_metric_value(message, source_platform, metric_alias) == 'N/A' ? 'NDA' : MetricsManager.get_metric_value(message, source_platform, metric_alias)
      else
        return metric_value
      end
    end
  end
end