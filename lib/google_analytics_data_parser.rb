class GoogleAnalyticsDataParser
  def self.parse(data)
    column_headers = data.column_headers
    rows = data.rows

    # TODO: This method really doesn't belong to the Message model; implement a Parser class once we get more sources of metrics
    # This method parses the data (returned by google-api-ruby-client) into a { message_param: { metric_1_name: metric_1_value } } hash
    # Step 1: Determine which column contains the ga:adContent dimension (The ga:adContent dimension should contain the to_param value of a message, which should be unique within any given installation of Trial Promoter.)
    ad_content_column_index = column_headers.index{ |column_header| column_header.name == 'ga:adContent' }
    raise MissingAdContentDimensionError if ad_content_column_index.nil?
    # Step 2: Get the metric column names
    metric_column_names = column_headers.select{ |column_header| column_header.column_type == 'METRIC' }.map(&:name)
    # Step 3: Get the indices (zero-based) of the metric columns 
    metric_column_indices = column_headers.each_index.select{|column_header| column_headers[column_header].column_type == 'METRIC'}
    # Step 4: Construct the parsed hash
    parsed_data = {}
    rows.each do |data_row|
      metric_hash = {}
      metric_column_names.each.with_index do |metric_column_name, index|
        metric_hash[metric_column_name] = data_row[metric_column_indices[index]].to_i
      end
      parsed_data[data_row[ad_content_column_index]] = metric_hash
    end
    
    parsed_data
  end
end