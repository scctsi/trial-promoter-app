require 'rails_helper'

RSpec.describe DataReportGenerator do
  before do
    @messages = create_list(:message, 5)

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
      message.message_template.experiment_variables['theme'] = ['1']
      metric = Metric.new(source: :google_analytics, data: {'ga:sessions'=>2, 'ga:users'=>2, 'ga:exits' =>2, 'ga:sessionDuration' => [42, 18], 'ga:timeOnPage' => [42, 18], 'ga:pageviews' => 2})
      message.metrics << metric

      message.website_session_count = 34
      message.save
    end
  end

  it 'creates a new data report file' do
    expect(DataReportGenerator.generate_report(@messages)).to eq(1)
  end
end