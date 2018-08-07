require "rails_helper"

RSpec.describe FacebookCommentsAggregatorJob, type: :job do
  include ActiveJob::TestHelper
  
  before do
    ActiveJob::Base.queue_adapter = :test
    @facebook_comments_aggregator = double('facebook_comments_aggregator')
    allow(FacebookCommentsAggregator).to receive(:new).and_return(@facebook_comments_aggregator)
    @experiment = create(:experiment)
    allow_any_instance_of(Experiment).to receive(:set_facebook_keys)
    
    @facebook_comments_aggregator = FacebookCommentsAggregator.new(@experiment)
  end
  
    it 'queues the job' do
    expect { FacebookCommentsAggregatorJob.perform_later(@experiment) }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end
  
  it 'queues the job in the default queue' do
    expect(FacebookCommentsAggregatorJob.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    perform_enqueued_jobs { FacebookCommentsAggregatorJob.perform_later(@experiment) }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end