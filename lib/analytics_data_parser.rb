class AnalyticsDataParser
  def self.parse_for_ospi(file_url, platform = :facebook, medium = :ad)
    # TODO: Unit test this
    # Step 1: Read file from the file's URL. Based on the filename, read in CSV or Excel data.
    if file_url.ends_with?('.csv')
      content = CsvFileReader.read(file_url, {:skip_first_row => true})
    end
    content = ExcelFileReader.new.read(file_url) if file_url.ends_with?('.xlsx')

    # Step 2: Look for the columns that we need
    ad_name_column_index = content[0].index("Ad Name")
    results_column_index = content[0].index("Results")
    reach_column_index = content[0].index("Reach")
    impressions_column_index = content[0].index("Impressions")
    link_clicks_column_index = content[0].index("Link Clicks")
    
    # Step 3: Go through every row in the data
    parsed_data = {}
    content.each.with_index do |row, index|
      next if index == 0 # Skip header row
      next if row[ad_name_column_index].blank?
      
      metrics = {}

      # Step 4: Add metrics from content 
      metrics[:results] = row[results_column_index].to_i
      metrics[:reach] = row[reach_column_index].to_i
      metrics[:impressions] = row[impressions_column_index].to_i
      metrics[:link_clicks] = row[link_clicks_column_index].to_i
      
      parsed_data[row[ad_name_column_index]] = metrics
    end
    
    # Step 5: Save the metrics
    p parsed_data
    parsed_data.each do |post_param, metrics|
      post = Post.find_by_param(post_param)
      post.metrics << Metric.new(source: platform, data: metrics)

      # Step 6: Calculate click rates
      post.click_rate = (metrics[:results].to_f / metrics[:impressions].to_f)

      post.save
    end
  end
  
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
        data.column_headers = ['social_network_id', '', '', '', '', '', '', '', '', '', '', 'impressions', '', '', '', 'likes', 'shares', 'comments', 'clicks']
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
      # matching_attribute_name is the name of the attribute on the message to match up to a column in the analytics file
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