require "rails_helper"

RSpec.describe GetAnalyticsFromClickMeterJob, type: :job do
  include ActiveJob::TestHelper
  
  before do
    ActiveJob::Base.queue_adapter = :test
    @message = create(:message)
    @message.click_meter_tracking_link = create(:click_meter_tracking_link)
    @message.click_meter_tracking_link.clicks << create_list(:click, 3, :sunday_clicks) 
    @message.save
  end
  
  it 'queues the job' do
    expect { GetAnalyticsFromClickMeterJob.perform_later(@experiment) }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end
  
  it 'queues the job in the default queue' do
    expect(GetAnalyticsFromClickMeterJob.new.queue_name).to eq('default')
  end 

  it 'executes perform' do
    # @click_meter_tracking_links.each { |tracking_link|
    # p @message.click_meter_tracking_link.click_meter_id 
      expect(ClickMeterClient).to receive(:get_clicks).with(@message.click_meter_tracking_link)
    # }
     perform_enqueued_jobs { GetAnalyticsFromClickMeterJob.perform_later(@message.click_meter_tracking_link) }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end