class AnalyticsDataParser
  def self.convert_to_parseable_data(csv_content, platform, medium)
    data = OpenStruct.new
    
    data.column_headers = ['service_update_id', '', '', '', 'impressions', '', '', 'retweets', 'replies', 'likes', '', 'clicks', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '']
    data.rows = csv_content[1..-1]
    
    data
  end
  
  def self.parse(data)
    # Step 1: Find the column which has the service update id
    service_update_id_column_index = data.column_headers.index('service_update_id')
    
    # Step 2: Go through every row in the data
    parsed_data = {}
    data.rows.each do |row|
      metrics = {}
      buffer_update = BufferUpdate.where(service_update_id: row[service_update_id_column_index])[0]
      
      data.column_headers.each.with_index do |column_header, index|
        if !column_header.blank? && !(column_header == 'service_update_id')
          metrics[column_header] = row[index].to_i
        end
      end
      parsed_data[buffer_update.message.to_param] = metrics
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
end