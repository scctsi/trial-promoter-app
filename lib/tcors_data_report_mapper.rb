class TcorsDataReportMapper
  IP_EXCLUSION_LIST = ['128.125.77.139', '128.125.132.141', '207.151.120.4', '128.125.98.4', '128.125.109.224', '128.125.98.2', '68.181.124.25', '162.225.230.188', '216.4.202.66', '68.181.207.160', '2605:e000:8681:4900:a5c8:66d1:4753:fcc0', '68.101.127.18', '2602:306:80c8:88a0:89a:a5f6:7641:321c' ]

  def self.stem(message)
    return message.message_template.experiment_variables['stem_id']
  end

  def self.fda_campaign(message)
    fda_campaign_mapping = { '1' => 'Fresh Empire', '2' => 'This Free Life'}
    return fda_campaign_mapping[message.message_template.experiment_variables['fda_campaign']]
  end

  def self.theme(message)
    theme_mapping = { '1' => 'Health', '2' => 'Appearance', '3' => 'Money', '4' => 'Love of Family', '5' => 'Addiction', '6' => 'Health + Community', '7' => 'Health + Family' }
    return theme_mapping[message.message_template.experiment_variables['theme']]
  end

  def self.lin_meth_factor(message)
    lin_meth_factor_mapping = { '1' => 'Perspective taking', '2' => 'Information packaging', '3' => 'Numeracy', '4' => 'Information packaging x Numeracy' }
    return lin_meth_factor_mapping[message.message_template.experiment_variables['lin_meth_factor']]
  end

  def self.lin_meth_level(message)
    lin_meth_level_mapping = { '1' => 'You', '2' => 'We', '3' => 'Everyone/Anyone', '4' => 'Specific new information mentioned first', '5' => 'Specific new information mentioned last', '6' => 'Raw numbers', '7' => 'Percentage', '8' =>'Specific new information mentioned first and raw numbers', '9' => 'Specific new information mentioned first and percentage', '10' => 'Specific new information mentioned last and raw numbers', '11' => 'Specific new information mentioned last and percentage' }
    return lin_meth_level_mapping[message.message_template.experiment_variables['lin_meth_level']]
  end

  def self.variant(message)
    return message.content
  end

  def self.sm_type(message)
    platform_mapper = {:twitter => 'T', :facebook => 'F', :instagram => 'I'}
    return platform_mapper[message.platform]
  end

  def self.day_experiment(message)
    return (message.scheduled_date_time.to_i - DateTime.new(2017, 4, 19).to_i) / 1.day.seconds
  end

  def self.date_sent(message)
    return message.scheduled_date_time.strftime("%m/%d/%Y")
  end

  def self.day_sent(message)
    #Ruby maps Sunday as 0, so mapper just follows data dictionary
    day_of_week_mapper = {'Sunday' => '7', 'Monday' => '1', 'Tuesday' => '2', 'Wednesday' => '3', 'Thursday' => '4', 'Friday' => '5', 'Saturday' => '6'}
    return day_of_week_mapper[message.scheduled_date_time.strftime("%A")]
  end

  def self.time_sent(message)
    if message.medium == :ad
      return 'N/A'
    else
      return message.scheduled_date_time.strftime("%H:%M:%S")
    end
  end

  def self.medium(message)
    return message.medium
  end

  def self.image_included(message)
    image_mapper = {'without' => 'No', 'with' => 'Yes'}
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
    unique_clicks = message.click_meter_tracking_link.clicks.select{|click| click.unique}
    click_times = unique_clicks.map{|click| click.click_time.strftime("%H:%M:%S")}
    return click_times
  end

  def self.total_impressions_day_1(message)
    return message.impressions_by_day[0]
  end

  def self.total_impressions_day_2(message)
    message.impressions_by_day = parse_organic_impressions(message) if message.medium == :organic
    return message.impressions_by_day[1]
  end

  def self.total_impressions_day_3(message)
    message.impressions_by_day = parse_organic_impressions(message) if message.medium == :organic
    return message.impressions_by_day[2]
  end

  def self.total_impressions_experiment(message)
    return message.get_total_impressions.last
  end

  def self.retweets_twitter(message)
    return MetricsManager.get_metric_value(message, :twitter, 'retweets')
  end

  def self.shares_facebook(message)
    return MetricsManager.get_metric_value(message, :facebook, 'shares')
  end

  def self.shares_instagram(message)
    return MetricsManager.get_metric_value(message, :instagram, 'shares')
  end

  def self.replies_twitter(message)
    return MetricsManager.get_metric_value(message, :twitter, 'replies')
  end

  def self.comments_facebook(message)
    return MetricsManager.get_metric_value(message, :facebook, 'comments')
  end

  def self.comments_instagram(message)
    return MetricsManager.get_metric_value(message, :instagram, 'comments')
  end

  def self.likes_twitter(message)
    return MetricsManager.get_metric_value(message, :twitter, 'likes')
  end

  def self.likes_facebook(message)
    return MetricsManager.get_metric_value(message, :facebook, 'likes')
  end

  def self.likes_instagram(message)
    return MetricsManager.get_metric_value(message, :instagram, 'likes')
  end

  def self.total_sessions_day_1(message)
    sessions = message.get_sessions(IP_EXCLUSION_LIST)
    return sessions.select{|session| session.started_at.between?(message.scheduled_date_time, message.scheduled_date_time + 1.day)}.count
  end

  def self.total_sessions_day_2(message)
    sessions = message.get_sessions(IP_EXCLUSION_LIST)
    return sessions.select{|session| session.started_at.between?(message.scheduled_date_time + 1.day, message.scheduled_date_time + 2.day)}.count
  end

  def self.total_sessions_day_3(message)
    sessions = message.get_sessions(IP_EXCLUSION_LIST)
    return sessions.select{|session| session.started_at.between?(message.scheduled_date_time + 2.day, message.scheduled_date_time + 3.day)}.count
  end

  def self.total_sessions_experiment(message)
    return message.website_session_count
  end

  def self.sessions(message)
    return MetricsManager.get_metric_value(message, :google_analytics, "ga:sessions")
  end

  def self.clicks(message)
    clicks = []
    sessions = message.get_sessions(IP_EXCLUSION_LIST)
    sessions.each do |session|
      clicks << Ahoy::Event.where(visit_id: session.id)
    end
    return clicks.count
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

  private
    def self.parse_organic_impressions(message)
      #check if organic impressions have been calulated for each day yet
      organic_impressions = message.get_total_impressions
      return organic_impressions if organic_impressions[4] == true

      organic_impressions[2] = organic_impressions[2] - organic_impressions[1]
      organic_impressions[1] = organic_impressions[1] - organic_impressions[0]
      organic_impressions[4] = true
      return organic_impressions
    end
end