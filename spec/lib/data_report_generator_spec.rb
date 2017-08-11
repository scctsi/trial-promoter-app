require 'rails_helper'

RSpec.describe DataReportGenerator do
  describe "(development only tests)", :development_only_tests => true do
    before do
        @messages = create_list(:message, 3)

        @messages.each do |message|
          message.scheduled_date_time = '30 April 2017 12:00:00'
          visits_1 = create_list(:visit, 3, utm_content: message.to_param, started_at: message.scheduled_date_time + 1.hour)
          visits_2 = create_list(:visit, 2, utm_content: message.to_param, started_at: message.scheduled_date_time + 1.day + 1.hour)
          visits_3 = create_list(:visit, 1, utm_content: message.to_param, started_at: message.scheduled_date_time + 2.day + 1.hour, ip: '128.125.77.139')
          visits_1.each do |visit|
            visit.ahoy_events << Ahoy::Event.new(visit_id: visit.id)
        end
        message.click_meter_tracking_link = create(:click_meter_tracking_link)
        message.click_meter_tracking_link.clicks << create_list(:click, 3, :unique => '1', :click_time => "30 April 2017 00:23:13")
        message.click_meter_tracking_link.clicks << create_list(:click, 1, :spider => '1', :click_time => "1 May 2017 12:34:57")
        message.click_meter_tracking_link.clicks << create_list(:click, 1, :unique => '1', :click_time => "1 May 2017 13:44:56")
        message.click_meter_tracking_link.clicks << create_list(:click, 2, :unique => '1', :click_time => "2 May 2017 19:26:01")
        message.impressions_by_day = [300, 800, 1400, 10000]
        message.message_template.experiment_variables['stem_id'] = 'FE51'
        message.message_template.experiment_variables['fda_campaign'] = '1'
        message.message_template.experiment_variables['theme'] = '1'
        message.message_template.experiment_variables['lin_meth_factor'] = '1'
        message.message_template.experiment_variables['lin_meth_level'] = '1'
        metric = Metric.new(source: :google_analytics, data: {'ga:sessions'=>2, 'ga:users'=>2, 'ga:exits' =>2, 'ga:sessionDuration' => [42, 18], 'ga:timeOnPage' => [42, 18], 'ga:pageviews' => 2})
        message.metrics << metric

        message.website_session_count = 34
        message.save
      end
    end
    it 'creates a new data report file' do
      column_names = ['stem', 'fda_campaign', 'theme', 'variant', 'lin_meth_factor', 'lin_meth_level', 'day_experiment', 'date_sent', 'day_sent', 'time_sent', 'sm_type', 'medium', 'image_included', 'total_clicks_day_1', 'total_clicks_day_2', 'total_clicks_day_3', 'total_clicks_experiment', 'click_time', 'total_impressions_day_1', 'total_impressions_day_2', 'total_impressions_day_3', 'total_impressions_experiment', 'retweets_twitter', 'shares_facebook', 'shares_instagram', 'replies_twitter', 'comments_facebook', 'comments_instagram', 'likes_twitter', 'likes_facebook', 'likes_instagram', 'total_sessions_day_1', 'total_sessions_day_2', 'total_sessions_day_3', 'total_sessions_experiment', 'sessions', 'clicks', 'users', 'exits', 'session_duration', 'time_on_page', 'pageviews']

      DataReportGenerator.generate_report(@messages, column_names)

      # Check contents of header
      csv_contents = CSV.read('data_report.csv')
      expect(csv_contents[0]).to eq(column_names)
      # Check if contents of the second row of CSV match first message
      column_names.each.with_index do |column_name, index|
        expect(TcorsDataReportMapper.send(column_name.to_sym, @messages[0]).to_s).to eq(csv_contents[1][index])
      end
      expect(csv_contents.count).to eq(@messages.count + 1)
    end
  end
end