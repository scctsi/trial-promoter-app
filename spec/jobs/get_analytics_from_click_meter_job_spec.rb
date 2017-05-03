require "rails_helper"

RSpec.describe GetAnalyticsFromClickMeterJob, type: :job do
  include ActiveJob::TestHelper
  
  before do
    ActiveJob::Base.queue_adapter = :test
    @click_meter_tracking_links = Message.all.map{ |message| message.click_meter_tracking_link }
    @click_meter_tracking_link.each { |link| link.clicks << create_list(:click, 3, :sunday_clicks) }
  end
  
  it 'queues the job' do
    expect { GetAnalyticsFromClickMeterJob.perform_later(@click_meter_tracking_links) }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end
  
  it 'queues the job in the default queue' do
    expect(GetAnalyticsFromClickMeterJob.new.queue_name).to eq('default')
  end

  it 'get clicks for tracking link' do
    @click_meter_tracking_links.each { |tracking_link|
      expect(ClickMeterClient).to receive(:get_clicks).with(tracking_link.clicks)
    }
    perform_enqueued_jobs { GetAnalyticsFromClickMeterJob.perform_later }
  end


  xit 'get clicks for tracking link' do
    expect(ClickMeterClient).to receive(:get_clicks).with(tracking_link.clicks)
  end


  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end