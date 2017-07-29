class TcorsDataReportMapper
  def self.stem(message)
    return message.message_template.experiment_variables['stem_id']
  end

  def self.fda_campaign(message)
    fda_campaign_mapping = { '1' => 'Fresh Empire', '2' => 'This Free Life'}
    return fda_campaign_mapping[message.message_template.experiment_variables['fda_campaign']]
  end

  def self.theme(message)
    theme_mapping = { '1' => 'Health', '2' => 'Community', '3' => 'Money', '4' => 'Family', '5' => 'Addiction' }
    themes = []
    message.message_template.experiment_variables['theme'].each do |theme|
      themes << theme_mapping[theme]
    end
    return themes.join(', ')
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
    platform_mapping = {:twitter => 'T', :facebook => 'F', :instagram => 'I'}
    return platform_mapping[message.platform]
  end

  def self.day_experiment(message)
    return (message.scheduled_date_time.to_i - DateTime.new(2017, 4, 19).to_i) / 1.day.seconds
  end

  def self.date_sent(message)
    return message.scheduled_date_time
  end

  def self.day_sent(message)
    return message.scheduled_date_time.strftime("%A")
  end

  def self.medium(message)
    return message.medium
  end

  def self.image_included(message)
    image_mapper = {'without' => 'No', 'with' => 'Yes'}
    return image_mapper[message.image_present]
  end

  def self.total_clicks_day1(message)
    return message.click_meter_tracking_link.get_daily_click_totals.first
  end

  def self.total_clicks_day2(message)
    return message.click_meter_tracking_link.get_daily_click_totals.second
  end

  def self.total_clicks_day3(message)
    return message.click_meter_tracking_link.get_daily_click_totals.third
  end

  def self.total_clicks_experiment(message)
    return message.click_meter_tracking_link.get_total_clicks
  end

  def self.click_time(message)
    unique_clicks = message.click_meter_tracking_link.clicks.select{|click| click.unique}
    click_times = unique_clicks.map{|click| click.click_time}
    return click_times
  end

  def self.total_impressions_day1
  end

  def self.total_impressions_day2
  end

  def self.total_impressions_day3
  end
end