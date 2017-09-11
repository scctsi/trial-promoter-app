require 'csv'

class TcorsDataReportGenerator
  # TODO: Unit test this
  COLUMN_NAMES = ['database_id', 'social_network_id', 'campaign_id', 'backdated', 'note', 'stem', 'fda_campaign', 'theme', 'lin_meth_factor', 'lin_meth_level', 'variant', 'sm_type', 'day_experiment', 'date_sent', 'day_sent', 'time_sent', 'medium', 'image_included', 'total_clicks_day_1', 'total_clicks_day_2', 'total_clicks_day_3', 'total_clicks_experiment', 'click_time', 'total_impressions_day_1', 'total_impressions_day_2', 'total_impressions_day_3', 'total_impressions_experiment', 'retweets_twitter', 'shares_facebook', 'shares_instagram', 'replies_twitter', 'comments_facebook', 'comments_instagram', 'likes_twitter', 'likes_facebook', 'likes_instagram', 'total_sessions_day_1', 'total_sessions_day_2', 'total_sessions_day_3', 'total_sessions_experiment', 'total_website_clicks_day_1', 'total_website_clicks_day_2', 'total_website_clicks_day_3', 'total_website_clicks_experiment', 'users', 'exits', 'session_duration', 'time_on_page', 'pageviews']
  def self.generate_report
    messages = Message.where('(backdated is null AND scheduled_date_time >= ? AND scheduled_date_time <= ?) OR (backdated is not null AND scheduled_date_time >= ? AND scheduled_date_time <= ?)', Date.new(2017, 4, 19), Date.new(2017, 7, 13), Date.new(2017, 4, 19), Date.new(2017, 7, 8)).order('scheduled_date_time ASC, platform ASC, medium ASC')
    file_name = "data_report_#{Time.now.year}_#{Time.now.month}_#{Time.now.day}_#{Time.now.hour}_#{Time.now.min}_#{Time.now.sec}.csv"

    CSV.open("#{Rails.root}/tmp/#{file_name}", "w", :write_headers => true, :headers => COLUMN_NAMES) do |csv|
        messages.each do |message|
        begin
          csv << [TcorsDataReportMapper.database_id(message), TcorsDataReportMapper.social_network_id(message), TcorsDataReportMapper.campaign_id(message), TcorsDataReportMapper.backdated(message), TcorsDataReportMapper.note(message), TcorsDataReportMapper.stem(message), TcorsDataReportMapper.fda_campaign(message), TcorsDataReportMapper.theme(message), TcorsDataReportMapper.lin_meth_factor(message), TcorsDataReportMapper.lin_meth_level(message),  TcorsDataReportMapper.variant(message), TcorsDataReportMapper.sm_type(message), TcorsDataReportMapper.day_experiment(message), TcorsDataReportMapper.date_sent(message), TcorsDataReportMapper.day_sent(message), TcorsDataReportMapper.time_sent(message), TcorsDataReportMapper.medium(message), TcorsDataReportMapper.image_included(message), TcorsDataReportMapper.total_clicks_day_1(message), TcorsDataReportMapper.total_clicks_day_2(message), TcorsDataReportMapper.total_clicks_day_3(message), TcorsDataReportMapper.total_clicks_experiment(message), TcorsDataReportMapper.click_time(message), TcorsDataReportMapper.total_impressions_day_1(message), TcorsDataReportMapper.total_impressions_day_2(message), TcorsDataReportMapper.total_impressions_day_3(message), TcorsDataReportMapper.total_impressions_experiment(message), TcorsDataReportMapper.retweets_twitter(message), TcorsDataReportMapper.shares_facebook(message), TcorsDataReportMapper.shares_instagram(message), TcorsDataReportMapper.replies_twitter(message), TcorsDataReportMapper.comments_facebook(message), TcorsDataReportMapper.comments_instagram(message), TcorsDataReportMapper.likes_twitter(message), TcorsDataReportMapper.reactions_facebook(message), TcorsDataReportMapper.reactions_instagram(message), TcorsDataReportMapper.total_sessions_day_1(message), TcorsDataReportMapper.total_sessions_day_2(message), TcorsDataReportMapper.total_sessions_day_3(message), TcorsDataReportMapper.total_sessions_experiment(message), TcorsDataReportMapper.total_website_clicks_day_1(message), TcorsDataReportMapper.total_website_clicks_day_2(message), TcorsDataReportMapper.total_website_clicks_day_3(message), TcorsDataReportMapper.total_website_clicks_experiment(message), TcorsDataReportMapper.users(message), TcorsDataReportMapper.exits(message), TcorsDataReportMapper.session_duration(message), TcorsDataReportMapper.time_on_page(message), TcorsDataReportMapper.pageviews(message)]
        rescue
          puts "I failed generating for #{message.id}"
          raise RuntimeError, "Stopping!"
        end
      end
    end
    
    dropbox_client = DropboxClient.new
    dropbox_client.store_file("/TCORS/data_reports/#{file_name}", IO.read("#{Rails.root}/tmp/#{file_name}"))
  end
end