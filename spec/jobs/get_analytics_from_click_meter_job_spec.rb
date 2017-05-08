require "rails_helper"

RSpec.describe GetAnalyticsFromClickMeterJob, type: :job do
  include ActiveJob::TestHelper
  
  before do
    ActiveJob::Base.queue_adapter = :test
    allow(ClickMeterClient).to receive(:get_clicks)
    experiment = create(:experiment)
    @messages = create_list(:message, 5, message_generating: experiment)
    @messages[0].publish_status = :published_to_buffer
    @messages[1].publish_status = :pending
    (3..4).each do |index|
      @messages[index].publish_status = :published_to_social_network
    end
    (0..4).each do |index|
      @messages[index].click_meter_tracking_link = create(:click_meter_tracking_link)
      @messages[index].click_meter_tracking_link.clicks << create_list(:click, 3, :click_time => '23 April 2017') 
      @messages[index].save
    end
  end
  
  it 'queues the job' do
    expect { GetAnalyticsFromClickMeterJob.perform_later(@experiment) }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end
  
  it 'queues the job in the default queue' do
    expect(GetAnalyticsFromClickMeterJob.new.queue_name).to eq('default')
  end 

  it 'executes perform' do
    (0..4).each do |index|
      expect(ClickMeterClient).to receive(:get_clicks).with(@messages[index].click_meter_tracking_link)
    end
    
    perform_enqueued_jobs { GetAnalyticsFromClickMeterJob.perform_later(@messages[3].click_meter_tracking_link) }
  end

  it 'only uses messages where the Buffer status is sent' do
    (0..4).each do |index|
      expect(ClickMeterClient).to receive(:message_valid?).with(@messages[index])

      perform_enqueued_jobs { GetAnalyticsFromClickMeterJob.perform_later(@messages[index].click_meter_tracking_link) }
    end
  end

  xit 'throttles the requests to 10 per second per the clickmeter api documentation' do
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end