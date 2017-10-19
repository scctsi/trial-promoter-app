class DataReportMapper
  attr_accessor :experiment
  
  def initialize(experiment)
    self.experiment = experiment
  end
  
  def database_id(message)
    return message.id
  end
  
  def campaign_id(message)
    return "CI: #{message.campaign_id}"
  end
  
  def social_network_id(message)
    return "SNI: #{message.social_network_id}"
  end
  
  def backdated(message)
    return "Yes" if message.backdated
    return "No"
  end
  
  def note(message)
    return message.note
  end

  def stem(message)
    return message.message_template.experiment_variables['stem_id']
  end

  def fda_campaign(message) 
    fda_campaign_mapper = { 'FE' => '1', 'TFL' => '2' }
    return fda_campaign_mapper[message.message_template.experiment_variables['fda_campaign']]
  end

  def theme(message)
    theme_mapper ={ 'health' => '1', 'appearace' => '2', 'money' => '3', 'love of family' => '4', 'addiction' => '5', 'health + community' => '6', 'health + family' => '7', 'UNCLEAR' => 'UNCLEAR' }
    return theme_mapper[message.message_template.experiment_variables['theme'].to_s]
  end

  def lin_meth_factor(message)
    return message.message_template.experiment_variables['lin_meth_factor'].to_s
  end

  def lin_meth_level(message)
    return message.message_template.experiment_variables['lin_meth_level'].to_s
  end

  def variant(message)
    content = message.message_template.content.chomp("{url}")
    return content
  end

  def sm_type(message)
    platform_mapper = {:twitter => 'T', :facebook => 'F', :instagram => 'I'}
    return platform_mapper[message.platform]
  end

  def day_experiment(message)
    return (message.scheduled_date_time.to_i - ActiveSupport::TimeZone.new("America/Los_Angeles").local(2017, 4, 19, 0, 0, 0).to_i) / 1.day.seconds + 1
  end

  def date_sent(message)
    return message.scheduled_date_time.strftime("%Y-%m-%d")
  end

  def day_sent(message)
    #Ruby maps Sunday as 0, so mapper just follows data dictionary
    day_of_week_mapper = {'Sunday' => '7', 'Monday' => '1', 'Tuesday' => '2', 'Wednesday' => '3', 'Thursday' => '4', 'Friday' => '5', 'Saturday' => '6'}
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

  def medium(message)
    medium_mapper = {:organic => '1', :ad => '2'}
    return medium_mapper[message.medium]
  end

  def image_included(message)
    image_mapper = {'without' => '0', 'with' => '1'}
    return image_mapper[message.image_present]
  end

  def total_clicks_day(message, day_offset = 0)
    all_clicks = message.click_meter_tracking_link.clicks.select{|click| click.click_time.to_date == (message.scheduled_date_time.to_date + day_offset.day)}
    return all_clicks
  end 
  
  def total_clicks_experiment(message)
    return message.click_meter_tracking_link.clicks.map
  end

  def click_time(all_clicks, creature = 'human', unique = true)  
    if creature == 'human'
      if unique == true
        click_times = all_clicks.map{|click| click.click_time.in_time_zone("America/Los_Angeles").strftime("%H:%M:%S") if (click.human? && click.unique == true) }.compact
      else
        click_times = all_clicks.map{|click| click.click_time.in_time_zone("America/Los_Angeles").strftime("%H:%M:%S") if (click.human? && !click.unique) }.compact
      end
    else
      if unique == true
        click_times = all_clicks.map{|click| click.click_time.in_time_zone("America/Los_Angeles").strftime("%H:%M:%S") if (!click.human? && click.unique == true) }.compact
      else
        click_times = all_clicks.map{|click| click.click_time.in_time_zone("America/Los_Angeles").strftime("%H:%M:%S") if (!click.human? && !click.unique) }.compact
      end
    end
    return click_times
  end

  def total_impressions_day(message, offset)
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

  def total_impressions_experiment(message)
    if message.platform == :instagram
      platform = :facebook
    else
      platform = message.platform
    end
    return get_metric(message, platform, 'impressions')
  end

  def retweets_twitter(message)
    if message.platform != :twitter
      return 'N/A'
    end
    return get_metric(message, message.platform, 'retweets')
  end

  def shares_facebook(message)
    if message.platform != :facebook
      return "N/A"
    else
      return get_metric(message, message.platform, 'shares')
    end
  end

  def shares_instagram(message)
    if message.platform != :instagram
      return "N/A"
    else
      return get_metric(message, :facebook, 'shares')
    end
  end

  def replies_twitter(message)
    if message.platform != :twitter
      return 'N/A'
    end
    return get_metric(message, message.platform, 'replies')
  end

  def comments_facebook(message)
    if message.platform != :facebook
      return "N/A"
    else
      return get_metric(message, message.platform, 'comments')
    end
  end

  def comments_instagram(message)
    if message.platform != :instagram
      return "N/A"
    else
      return get_metric(message, :facebook, 'comments')
    end
  end

  def likes_twitter(message)
    if message.platform != :twitter
      return 'N/A'
    end
    return get_metric(message, message.platform, 'likes')
    # return MetricsManager.get_metric_value(message, :twitter, 'likes') == 'N/A' ? 'NDA' : MetricsManager.get_metric_value(message, :twitter, 'likes')
  end

  def reactions_facebook(message)
    if message.platform != :facebook
      return "N/A"
    else
      reactions = MetricsManager.get_metric_value(message, :facebook, 'reactions')
      if  reactions == "N/A"
        return MetricsManager.get_metric_value(message, :facebook, 'likes') == 'N/A' ? 'NDA' : MetricsManager.get_metric_value(message, :facebook, 'likes')
      else
        return reactions
      end
    end
  end

  def reactions_instagram(message)
    if message.platform != :instagram
      return "N/A"
    else
      reactions = MetricsManager.get_metric_value(message, :facebook, 'reactions')
      if  reactions == "N/A"
        return MetricsManager.get_metric_value(message, :facebook, 'likes')  == 'N/A' ? 'NDA' : MetricsManager.get_metric_value(message, :facebook, 'likes')
      else
        return reactions
      end
    end
  end

  def total_sessions_day(message, offset = 0, ip_exclusion_list)
    scheduled_start_of_day = (message.scheduled_date_time + offset.day)
    scheduled_end_of_day = scheduled_start_of_day.end_of_day
    return message.get_sessions(scheduled_start_of_day, scheduled_end_of_day, ip_exclusion_list).count
  end

  def total_sessions_experiment(message, ip_exclusion_list)
    return message.get_sessions(DateTime.new(1970, 1, 1), DateTime.new(2100, 1, 1), ip_exclusion_list).count
  end
  
  def total_website_clicks_day(message, offset = 0)
    return calculate_goal_count(message, message.scheduled_date_time + offset.day)
  end

  def total_website_clicks_experiment(message, ip_exclusion_list)
    goal_count = 0
    sessions = message.get_sessions(DateTime.new(1970, 1, 1), DateTime.new(2100, 1, 1), ip_exclusion_list)
    sessions.each do |session|
      goal_count += 1 if Ahoy::Event.where(visit_id: session.id).where(name: "Converted").count > 0
    end
    return goal_count
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
    goal_count = 0
    sessions = message.get_sessions(date.beginning_of_day, date.end_of_day, message.message_generating.ip_exclusion_list)
    sessions.each do |session|
      goal_count += 1 if Ahoy::Event.where(visit_id: session.id).where(name: "Converted").count > 0
    end
    return goal_count 
  end
  
  def get_metric(message, platform, metric)
     MetricsManager.get_metric_value(message, platform, metric)  == 'N/A' ? 'NDA' : MetricsManager.get_metric_value(message, platform, metric)
  end
end