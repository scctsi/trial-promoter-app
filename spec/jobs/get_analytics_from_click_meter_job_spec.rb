require "rails_helper"

RSpec.describe GetAnalyticsFromClickMeterJob, type: :job do
  include ActiveJob::TestHelper
  
  before do
    ActiveJob::Base.queue_adapter = :test
    @click_meter_tracking_links = create_list(:click_meter_tracking_link, 3)
    @click_meter_client = ClickMeterClient.new
  end
  
  it 'queues the job' do
    expect { GetAnalyticsFromClickMeterJob.perform_later(@click_meter_client) }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end
  
  xit 'queues the job in the default queue' do
    expect(GetAnalyticsFromClickMeterJob.new.queue_name).to eq('default')
  end

  xit 'get clicks for tracking link' do
    @click_meter_tracking_links.each { |tracking_link| 
      expect(ClickMeterClient).to receive(:get_clicks).with(tracking_link)
    }
    perform_enqueued_jobs { GetAnalyticsFromClickMeterJob.perform_later }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end