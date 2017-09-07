class TcorsDataReportMapper
  IP_EXCLUSION_LIST = ['128.125.77.139', '128.125.132.141', '207.151.120.4', '128.125.98.4', '128.125.109.224', '128.125.98.2', '68.181.124.25', '162.225.230.188', '216.4.202.66', '68.181.207.160', '2605:e000:8681:4900:a5c8:66d1:4753:fcc0', '68.101.127.18', '2602:306:80c8:88a0:89a:a5f6:7641:321c' ]

  def self.database_id(message)
    return message.id
  end
  
  def self.campaign_id(message)
    return message.campaign_id
  end
  
  def self.social_network_id(message)
    return message.social_network_id
  end
  
  def self.note(message)
    return message.note
  end

  def self.stem(message)
    return message.message_template.experiment_variables['stem_id']
  end

  def self.fda_campaign(message)
    fda_campaign_mapper = { 'FE' => '1', 'TFL' => '2' }
    return fda_campaign_mapper[message.message_template.experiment_variables['fda_campaign']]
  end

  def self.theme(message)
    theme_mapper ={ 'health' => '1', 'appearace' => '2', 'money' => '3', 'love of family' => '4', 'addiction' => '5', 'health + community' => '6', 'health + family' => '7', 'UNCLEAR' => 'UNCLEAR' }
    return theme_mapper[message.message_template.experiment_variables['theme'].to_s]
  end

  def self.lin_meth_factor(message)
    return message.message_template.experiment_variables['lin_meth_factor'].to_s
  end

  def self.lin_meth_level(message)
    return message.message_template.experiment_variables['lin_meth_level'].to_s
  end

  def self.variant(message)
    content = message.message_template.content.chomp("{url}")
    return content
  end

  def self.sm_type(message)
    platform_mapper = {:twitter => 'T', :facebook => 'F', :instagram => 'I'}
    return platform_mapper[message.platform]
  end

  def self.day_experiment(message)
    return (message.scheduled_date_time.to_i - ActiveSupport::TimeZone.new("America/Los_Angeles").local(2017, 4, 19, 0, 0, 0).to_i) / 1.day.seconds + 1
  end

  def self.date_sent(message)
    return message.scheduled_date_time.strftime("%Y-%m-%d")
  end

  def self.day_sent(message)
    #Ruby maps Sunday as 0, so mapper just follows data dictionary
    day_of_week_mapper = {'Sunday' => '7', 'Monday' => '1', 'Tuesday' => '2', 'Wednesday' => '3', 'Thursday' => '4', 'Friday' => '5', 'Saturday' => '6'}
    return day_of_week_mapper[message.scheduled_date_time.strftime("%A")]
  end

  def self.time_sent(message)
    if message.medium == :ad
      return 'N/A'
    elsif message.buffer_update.sent_from_date_time.nil?
      return 'N/A'
    else  
      return message.buffer_update.sent_from_date_time.strftime("%H:%M:%S")
    end
  end

  def self.medium(message)
    medium_mapper = {:organic => '1', :ad => '2'}
    return medium_mapper[message.medium]
  end

  def self.image_included(message)
    image_mapper = {'without' => '0', 'with' => '1'}
    return image_mapper[message.image_present]
  end

  def self.total_clicks_day_1(message)
    return message.click_meter_tracking_link.get_daily_click_totals.first
  end

  def self.total_clicks_day_2(message)
    return message.click_meter_tracking_link.get_daily_click_totals.second
  end

  def self.total_clicks_day_3(message)
    return message.click_meter_tracking_link.get_daily_click_totals.third
  end

  def self.total_clicks_experiment(message)
    return message.click_meter_tracking_link.get_total_clicks
  end

  def self.click_time(message)
    unique_clicks = message.click_meter_tracking_link.clicks.select{|click| click.human? && click.unique}
    scheduled_start_of_day = message.scheduled_date_time
    scheduled_end_of_day = scheduled_start_of_day.end_of_day
    click_times = []
    # get click times for each calendar day and store as nested arrays 
    3.times do
      click_times << ((unique_clicks.map{|click| click.click_time.strftime("%H:%M:%S") if click.human? && click.click_time.between?(scheduled_start_of_day, scheduled_end_of_day)}).compact )
      scheduled_start_of_day = (scheduled_start_of_day + 1.day).beginning_of_day
      scheduled_end_of_day = (scheduled_end_of_day + 1.day).end_of_day
    end
    return click_times
  end 

  def self.total_impressions_day_1(message)
    if message.impressions_by_day[message.scheduled_date_time.to_date].nil?
      return 0
    else
      return message.impressions_by_day[message.scheduled_date_time.to_date] 
    end
  end

  def self.total_impressions_day_2(message)
    return 0 if message.impressions_by_day[(message.scheduled_date_time + 1.day).to_date].nil?
    if message.medium == :organic
      return message.impressions_by_day[(message.scheduled_date_time + 1.day).to_date] - self.total_impressions_day_1(message)
    else
      return message.impressions_by_day[(message.scheduled_date_time + 1.day).to_date]
    end
  end

  def self.total_impressions_day_3(message)
    return 0 if message.impressions_by_day[(message.scheduled_date_time + 2.day).to_date].nil?
    if message.medium == :organic
      return message.impressions_by_day[(message.scheduled_date_time + 2.day).to_date] - self.total_impressions_day_2(message) - self.total_impressions_day_1(message)
    else
      return message.impressions_by_day[(message.scheduled_date_time + 2.day).to_date]
    end
  end

  def self.total_impressions_experiment(message)
    if message.platform == :instagram
      platform = :facebook
    else
      platform = message.platform
    end
    return MetricsManager.get_metric_value(message, platform, 'impressions') 
  end

  def self.retweets_twitter(message)
    return MetricsManager.get_metric_value(message, :twitter, 'retweets')
  end

  def self.shares_facebook(message)
    if message.platform != :facebook
      return "N/A"
    else
      return MetricsManager.get_metric_value(message, :facebook, 'shares')
    end
  end

  def self.shares_instagram(message)
    if message.platform != :instagram
      return "N/A"
    else
      return MetricsManager.get_metric_value(message, :facebook, 'shares')
    end
  end

  def self.replies_twitter(message)
    return MetricsManager.get_metric_value(message, :twitter, 'replies')
  end

  def self.comments_facebook(message)
    if message.platform != :facebook
      return "N/A"
    else
      return MetricsManager.get_metric_value(message, :facebook, 'comments')
    end
  end

  def self.comments_instagram(message)
    if message.platform != :instagram
      return "N/A"
    else
      return MetricsManager.get_metric_value(message, :facebook, 'comments')
    end
  end

  def self.likes_twitter(message)
    return MetricsManager.get_metric_value(message, :twitter, 'likes')
  end

  def self.reactions_facebook(message)
    if message.platform != :facebook
      return "N/A"
    else
      reactions = MetricsManager.get_metric_value(message, :facebook, 'reactions')
      if  reactions == "N/A"
        return MetricsManager.get_metric_value(message, :facebook, 'likes')
      else
        return reactions
      end
    end
  end

  def self.reactions_instagram(message)
    if message.platform != :instagram
      return "N/A"
    else
      reactions = MetricsManager.get_metric_value(message, :facebook, 'reactions')
      if  reactions == "N/A"
        return MetricsManager.get_metric_value(message, :facebook, 'likes')
      else
        return reactions
      end
    end
  end

  def self.total_sessions_day_1(message)
    scheduled_start_of_day = message.scheduled_date_time
    scheduled_end_of_day = scheduled_start_of_day.end_of_day
    return get_sessions(message, scheduled_start_of_day, scheduled_end_of_day).count
  end

  def self.total_sessions_day_2(message)
    scheduled_start_of_day = (message.scheduled_date_time + 1.day).beginning_of_day
    scheduled_end_of_day = (scheduled_start_of_day).end_of_day
    return get_sessions(message, scheduled_start_of_day, scheduled_end_of_day).count
  end

  def self.total_sessions_day_3(message)
    scheduled_start_of_day = (message.scheduled_date_time + 2.day).beginning_of_day
    scheduled_end_of_day = (scheduled_start_of_day).end_of_day 
    return get_sessions(message, scheduled_start_of_day, scheduled_end_of_day).count
  end

  def self.total_sessions_experiment(message)
    return message.get_sessions(IP_EXCLUSION_LIST).count
  end
  
  def self.total_goals_day_1(message)
    return calculate_goal_count(message, message.scheduled_date_time)
  end

  def self.total_goals_day_2(message)
    return calculate_goal_count(message, message.scheduled_date_time + 1.day)
  end

  def self.total_goals_day_3(message)
    return calculate_goal_count(message, message.scheduled_date_time + 2.day)
  end

  def self.total_goals_experiment(message)
    goals = []
    experiment_start = DateTime.parse('19 April 2017')
    experiment_finish = DateTime.parse('15 July 2017')
    sessions = get_sessions(message, experiment_start, experiment_finish)
    sessions.each do |session|
      goals << Ahoy::Event.where(visit_id: session.id).where(name: "Converted")
    end
    return goals.count
  end

  def self.users(message)
    return MetricsManager.get_metric_value(message, :google_analytics, 'ga:users')
  end

  def self.exits(message)
    return MetricsManager.get_metric_value(message, :google_analytics, 'ga:exits')
  end

  def self.session_duration(message)
    return MetricsManager.get_metric_value(message, :google_analytics, 'ga:sessionDuration')
  end

  def self.time_on_page(message)
    return MetricsManager.get_metric_value(message, :google_analytics, 'ga:timeOnPage')
  end

  def self.pageviews(message)
    return MetricsManager.get_metric_value(message, :google_analytics, 'ga:pageviews')
  end

  def self.get_sessions(message, start, finish)
    sessions = message.get_sessions(IP_EXCLUSION_LIST)
    return sessions.select{|session| session.started_at.between?(start, finish)}
  end
  
  private
  def self.calculate_goal_count(message, date)
    goal_count = 0
    sessions = get_sessions(message, date.beginning_of_day, date.end_of_day)
    sessions.each do |session|
      goal_count += 1 if Ahoy::Event.where(visit_id: session.id).where(name: "Converted").count > 0
    end
    return goal_count 
  end
end