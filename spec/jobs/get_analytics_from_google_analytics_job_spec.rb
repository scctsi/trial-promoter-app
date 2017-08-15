require "rails_helper"

RSpec.describe GetAnalyticsFromGoogleAnalyticsJob, type: :job do
  include ActiveJob::TestHelper

  before do
    ActiveJob::Base.queue_adapter = :test
    @google_analytics_client = double('google_analytics')
    allow(GoogleAnalyticsClient).to receive(:new).and_return(@google_analytics_client)
    @data = []
    @parsed_data = []
    allow(@google_analytics_client).to receive(:get_data).and_return(@data)
    allow(GoogleAnalyticsDataParser).to receive(:parse).and_return(@parsed_data)
    allow(GoogleAnalyticsDataParser).to receive(:store)
  end

  it 'queues the job' do
    expect { GetAnalyticsFromGoogleAnalyticsJob.perform_later }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'queues the job in the default queue' do
    expect(GetAnalyticsFromGoogleAnalyticsJob.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    perform_enqueued_jobs { GetAnalyticsFromGoogleAnalyticsJob.perform_later }

    expect(@google_analytics_client).to have_received(:get_data).with(Date.new(2017,4,19).to_s, DateTime.now.to_date.to_s)
    expect(GoogleAnalyticsDataParser).to have_received(:parse).with(@data)
    expect(GoogleAnalyticsDataParser).to have_received(:store).with(@parsed_data)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end