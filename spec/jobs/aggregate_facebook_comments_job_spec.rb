require "rails_helper"

RSpec.describe AggregateFacebookCommentsJob, type: :job do
  include ActiveJob::TestHelper
  
  before do
    ActiveJob::Base.queue_adapter = :test
    @experiment = create(:experiment)
    allow_any_instance_of(Experiment).to receive(:configure_settings)
    
    @facebook_comments_aggregator = FacebookCommentsAggregator.new(@experiment.configure_settings)
  end
  
    it 'queues the job' do
    expect { AggregateFacebookCommentsJob.perform_later(@experiment) }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end
  
  it 'queues the job in the default queue' do
    expect(AggregateFacebookCommentsJob.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    expect_any_instance_of(Experiment).to receive(:create_messages)
    
    perform_enqueued_jobs { AggregateFacebookCommentsJob.perform_later(@experiment) }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end