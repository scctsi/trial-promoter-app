require 'open-uri'

class MetricFileParser
  # This class contains all the code that parses the content of a CSV file that contains 
  # metrics for a social media platform.
  def to_metric(csv_line_array, source)
    data = {
      impressions: csv_line_array[4],
      engagements: csv_line_array[5],
      engagement_rate: csv_line_array[6],
      retweets: csv_line_array[7],
      replies: csv_line_array[8],
      favorites: csv_line_array[9],
      user_profile_clicks: csv_line_array[10],
      url_clicks: csv_line_array[11],
      hashtag_clicks: csv_line_array[12],
      detail_expands: csv_line_array[13],
      permalink_clicks: csv_line_array[14]
    }

    Metric.new(data: data, source: source)
  end
  
  def parse_line(csv_line_array, source)
    message = Message.find_by_service_update_id(csv_line_array[0])
    
    if message != nil
      message.metrics << to_metric(csv_line_array, source)
      message.save
    end
  end
  
  def parse(csv_lines_array, source)
    csv_lines_array.each_with_index do |csv_line_array, index|
      parse_line(csv_line_array, source) if index != 0
    end
  end
  
  def read_from_url(url)
    csv_lines_array = CSV.new(open(url)).read
    csv_lines_array
  end
  
  def parse_from_url(url, source)
    parse(read_from_url(url), source)
  end
end