class DataImporter
  include HTTParty

  def import_buffer_data
    Message.where('sent_to_buffer_at is not null').each do |message|
      if !message.buffer_update_id.blank?
        response = HTTParty.get("https://api.bufferapp.com/1/updates/#{message.buffer_update_id}.json?access_token=********")

        if response.has_key?('statistics')
          message.statistics = response['statistics']
        end

        if message.sent_from_buffer_at.blank? and response.has_key?('sent_at')
          message.sent_from_buffer_at = DateTime.strptime(response['sent_at'].to_s, '%s')
        end

        if response.has_key?('sent_at')
          message.service_update_id = response['service_update_id']
        end

        message.save
      end
    end
  end

  def process_buffer_data
    if DimensionMetric.where("dimensions = ?", ['twitter', 'organic'].to_yaml).count != 0
      twitter_organic_dimension_metric = DimensionMetric.where("dimensions = ?", ['twitter', 'organic'].to_yaml)[0]
    else
      twitter_organic_dimension_metric = DimensionMetric.new(:dimensions => ['twitter', 'organic'])
    end

    if DimensionMetric.where("dimensions = ?", ['facebook', 'organic'].to_yaml).count != 0
      facebook_organic_dimension_metric = DimensionMetric.where("dimensions = ?", ['facebook', 'organic'].to_yaml)[0]
    else
      facebook_organic_dimension_metric = DimensionMetric.new(:dimensions => ['facebook', 'organic'])
    end

    if DimensionMetric.where("dimensions = ?", ['facebook', 'paid'].to_yaml).count != 0
      facebook_paid_dimension_metric = DimensionMetric.where("dimensions = ?", ['facebook', 'paid'].to_yaml)[0]
    else
      facebook_paid_dimension_metric = DimensionMetric.new(:dimensions => ['facebook', 'paid'])
    end

    twitter_organic_metrics = { 'retweets' => 0, 'favorites' => 0, 'mentions' => 0, 'clicks' => 0, 'reach' => 0 }
    facebook_organic_metrics = { 'comments' => 0, 'likes' => 0, 'reach' => 0, 'shares' => 0, 'clicks' => 0 }
    facebook_paid_metrics = { 'comments' => 0, 'likes' => 0, 'reach' => 0, 'shares' => 0, 'clicks' => 0 }

    Message.where('sent_to_buffer_at is not null and statistics is not null').each do |message|
      if message.message_template.platform.start_with?('twitter')
        twitter_organic_metrics['retweets'] += message.statistics['retweets']
        twitter_organic_metrics['favorites'] += message.statistics['favorites']
        twitter_organic_metrics['mentions'] += message.statistics['mentions']
        twitter_organic_metrics['clicks'] += message.statistics['clicks']
        twitter_organic_metrics['reach'] += message.statistics['reach']
      end

      if message.message_template.platform.start_with?('facebook') and message.medium == 'organic'
        facebook_organic_metrics['comments'] += message.statistics['comments']
        facebook_organic_metrics['likes'] += message.statistics['likes']
        facebook_organic_metrics['reach'] += message.statistics['reach']
        facebook_organic_metrics['shares'] += message.statistics['shares']
        facebook_organic_metrics['clicks'] += message.statistics['clicks']
      end

      if message.message_template.platform.start_with?('facebook') and message.medium == 'paid'
        facebook_paid_metrics['comments'] += message.statistics['comments']
        facebook_paid_metrics['likes'] += message.statistics['likes']
        facebook_paid_metrics['reach'] += message.statistics['reach']
        facebook_paid_metrics['shares'] += message.statistics['shares']
        facebook_paid_metrics['clicks'] += message.statistics['clicks']
      end
    end

    twitter_organic_dimension_metric.metrics = twitter_organic_metrics
    twitter_organic_dimension_metric.save
    facebook_organic_dimension_metric.metrics = facebook_organic_metrics
    facebook_organic_dimension_metric.save
    facebook_paid_dimension_metric.metrics = facebook_paid_metrics
    facebook_paid_dimension_metric.save
  end

  def import_twitter_data
    csv_text = File.read(Rails.root.join('data_dumps', 'twitter_activity_metrics_20150901_20151001.csv'))
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      twitter_messages = Message.where('service_update_id = ?', row[0].to_s)
      if twitter_messages.count > 0
        twitter_messages[0].service_statistics = { 'retweets' => row[7].to_i, 'favorites' => row[9].to_i, 'replies' => row[8].to_i, 'clicks' => row[11].to_i, 'user_profile_clicks' => row[10].to_i, 'impressions' => row[4].to_i}
        twitter_messages[0].save
      end
    end
  end

  def process_twitter_data
    if DimensionMetric.where("dimensions = ?", ['twitter', 'organic', 'twitter_analytics'].to_yaml).count != 0
      twitter_organic_twitter_analytics_dimension_metric = DimensionMetric.where("dimensions = ?", ['twitter', 'organic', 'twitter_analytics'].to_yaml)[0]
    else
      twitter_organic_twitter_analytics_dimension_metric = DimensionMetric.new(:dimensions => ['twitter', 'organic', 'twitter_analytics'])
    end

    twitter_organic_metrics = { 'retweets' => 0, 'favorites' => 0, 'replies' => 0, 'clicks' => 0, 'user_profile_clicks' => 0, 'impressions' => 0}

    Message.where('sent_to_buffer_at is not null and service_statistics is not null').each do |message|
      twitter_organic_metrics['retweets'] += message.service_statistics['retweets']
      twitter_organic_metrics['favorites'] += message.service_statistics['favorites']
      twitter_organic_metrics['replies'] += message.service_statistics['replies']
      twitter_organic_metrics['clicks'] += message.service_statistics['clicks']
      twitter_organic_metrics['user_profile_clicks'] += message.service_statistics['user_profile_clicks']
      twitter_organic_metrics['impressions'] += message.service_statistics['impressions']
    end

    twitter_organic_twitter_analytics_dimension_metric.metrics = twitter_organic_metrics
    twitter_organic_twitter_analytics_dimension_metric.save
  end

  def import_facebook_data
    csv_text = File.read(Rails.root.join('data_dumps', 'twitter_activity_metrics_20150901_20151001.csv'))
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      twitter_messages = Message.where('service_update_id = ?', row[0].to_s)
      if twitter_messages.count > 0
        twitter_messages[0].service_statistics = { 'retweets' => row[7].to_i, 'favorites' => row[9].to_i, 'replies' => row[8].to_i, 'clicks' => row[11].to_i, 'user_profile_clicks' => row[10].to_i, 'impressions' => row[4].to_i}
        twitter_messages[0].save
      end
    end
  end

  def import_google_analytics_data
    dimension_metrics = {}

    dimensions = ['twitter', 'organic', 'google_analytics']
    dimension_metrics[dimensions] = find_or_build_dimension_metric(dimensions)
    dimensions = ['facebook', 'organic', 'google_analytics']
    dimension_metrics[dimensions] = find_or_build_dimension_metric(dimensions)
    dimensions = ['facebook', 'paid', 'google_analytics']
    dimension_metrics[dimensions] = find_or_build_dimension_metric(dimensions)
    dimensions = ['google', 'paid', 'google_analytics']
    dimension_metrics[dimensions] = find_or_build_dimension_metric(dimensions)
    dimensions = ['youtube_search_results', 'paid', 'google_analytics']
    dimension_metrics[dimensions] = find_or_build_dimension_metric(dimensions)
    dimensions = ['profiles', 'organic', 'google_analytics']
    dimension_metrics[dimensions] = find_or_build_dimension_metric(dimensions)
    dimensions = ['outside_campaign', 'all', 'google_analytics']
    dimension_metrics[dimensions] = find_or_build_dimension_metric(dimensions)

    csv_text = File.read(Rails.root.join('data_dumps', 'google-metrics-all.csv'))
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      if row[0] == 'trial-promoter'
        source = row[1].split('/')[0].strip
        medium = row[1].split('/')[1].strip

        metrics = {
          'sessions' => row[2],
          'percentage_new_sessions' => row[3],
          'new_users' => row[4],
          'bounce_rate' => row[5],
          'pages_per_session' => row[6],
          'average_session_duration' => row[7],
          'conversion_rate' => row[8],
          'conversions' => row[9]
        }

        dimension_metrics[[source, medium, 'google_analytics']].metrics = metrics
        dimension_metrics[[source, medium, 'google_analytics']].save
      end
    end

    csv_text = File.read(Rails.root.join('data_dumps', 'google-metrics-all-referrer.csv'))
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      if row[0] == 'profiles.sc-ctsi.org/shindigusc/gadgets/ifr'
        source = 'profiles'
        medium = 'organic'

        metrics = {
            'sessions' => row[2],
            'percentage_new_sessions' => row[3],
            'new_users' => row[4],
            'bounce_rate' => row[5],
            'pages_per_session' => row[6],
            'average_session_duration' => row[7],
            'conversion_rate' => row[8],
            'conversions' => row[9]
        }

        dimension_metrics[[source, medium, 'google_analytics']].metrics = metrics
        dimension_metrics[[source, medium, 'google_analytics']].save
      end
    end
  end

  def process_google_analytics_data

  end

  def find_or_build_dimension_metric(dimensions)
    if DimensionMetric.where("dimensions = ?", dimensions.to_yaml).count != 0
      return DimensionMetric.where("dimensions = ?", dimensions.to_yaml)[0]
    else
      return DimensionMetric.new(:dimensions => dimensions)
    end
  end
end