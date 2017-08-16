class AnalyticsDataParser
  def self.convert_to_parseable_data(content, platform, medium)
    data = OpenStruct.new

    case platform
    when :twitter
      case medium
      when :organic
        data.column_headers = ['social_network_id', '', '', '', 'impressions', '', '', 'retweets', 'replies', 'likes', '', 'clicks', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '']
        data.rows = content[1..-1]
      when :ad
        data.column_headers = ['', '', '', '', '', '', 'social_network_id', '', 'impressions', '', 'likes', 'retweets', 'replies', 'clicks']
        data.rows = content[1..-1]
      end
    when :facebook
      case medium
      when :organic
        data.column_headers = ['social_network_id', '', '', '', '', '', '', '', '', '', '', 'impressions', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 'comments', 'likes', 'shares', '', 'clicks']
        data.rows = content[2..-1]
      when :ad
        data.column_headers = ['', '', 'campaign_id', 'impressions', '', 'shares', 'comments', '', 'reactions', '', '', '', '']
        data.rows = content[1..-1]
      end
    end

    data
  end

  def self.parse(data, matching_attribute_name = 'social_network_id')
    # Step 1: Find the column which has the service update id
    matching_id_column_index = data.column_headers.index(matching_attribute_name)

    # Step 2: Go through every row in the data
    parsed_data = {}
    data.rows.each do |row|
      metrics = {}
      # matching_atttribute_name is the name of the attribute on the message to match up to a column in the analytics file
      # For Twitter ad, Twitter organic, Facebook organic, the social_network_id is present in the analytics file
      # For Facebook ad and Instagram ad, the campaign_id (entered manually) needs to be matched up to the corresponding column in the anlytics file
      message = Message.where(matching_attribute_name => row[matching_id_column_index])[0]
      next if message.nil?

      data.column_headers.each.with_index do |column_header, index|
        if !column_header.blank? && !(column_header == matching_attribute_name)
          metrics[column_header] = row[index].to_i
        end
      end
      parsed_data[message.to_param] = metrics
    end

    parsed_data
  end

  def self.store(parsed_data, source)
    parsed_data.each do |message_param, metrics|
      message = Message.find_by_param(message_param)
      message.metrics << Metric.new(source: source, data: metrics)
      message.save
    end
  end

  def self.transform(data, options)
    case options[:operation]
    when :parse_tweet_id_from_permalink
      data.rows.each do |row|
        row[0] = row[1][(row[1].rindex('/') + 1)..-1]
      end
    end

    data
  end
end