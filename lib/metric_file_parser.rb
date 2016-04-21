require 'open-uri'

class MetricFileParser
  # This class contains all the code that parses the content of a CSV file that contains 
  # metrics for a social media platform.
  def to_metric(csv_line_array, source)
    if source == :twitter
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
    end
  
    if source == :facebook
      data = {
        lifetime_post_total_reach: csv_line_array[8],
        lifetime_post_organic_reach: csv_line_array[9],
        lifetime_post_paid_reach: csv_line_array[10],
        lifetime_post_total_impressions: csv_line_array[11],
        lifetime_post_organic_impressions: csv_line_array[12],
        lifetime_post_paid_impressions: csv_line_array[13],
        lifetime_engaged_users: csv_line_array[14],
        lifetime_post_consumers: csv_line_array[15],
        lifetime_post_consumptions: csv_line_array[16],
        lifetime_negative_feedback: csv_line_array[17],
        lifetime_negative_feedback_from_users: csv_line_array[18],
        lifetime_post_impressions_by_people_who_have_liked_your_page: csv_line_array[19],
        lifetime_post_reach_by_people_who_like_your_page: csv_line_array[20],
        lifetime_post_paid_impressions_by_people_who_have_liked_your_page: csv_line_array[21],
        lifetime_paid_reach_of_a_post_by_people_who_like_your_page: csv_line_array[22],
        lifetime_people_who_have_liked_your_page_and_engaged_with_your_post: csv_line_array[23],
      }
    end

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