require "rails_helper"

RSpec.describe GetFacebookMetricsJob, type: :job do
  include ActiveJob::TestHelper

  before do
    ActiveJob::Base.queue_adapter = :test
    @facebook_metrics_aggregator = double('facebook_metrics_aggregator')
    allow(FacebookMetricsAggregator).to receive(:new).and_return(@facebook_metrics_aggregator)
    @page = "980601328736431"
    @start_date = "Wed, 19 Apr 2017"
    @end_date = "Wed, 13 Jul 2017"
    @data = []
    allow(@facebook_metrics_aggregator).to receive(:get_posts).with(@page, @start_date, @end_date).and_return(@data)
  end

  it 'queues the job' do
    expect { GetFacebookMetricsJob.perform_later }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'queues the job in the default queue' do
    expect(GetFacebookMetricsJob.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    perform_enqueued_jobs { GetFacebookMetricsJob.perform_later(@page, @start_date, @end_date) }

    expect(@facebook_metrics_aggregator).to have_received(:get_posts).with(@page, @start_date, @end_date)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end