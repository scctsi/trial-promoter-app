# REF: https://medium.com/@chuckjhardy/testing-rails-activejob-with-rspec-5c3de1a64b66#.2cmux4kvm
require "rails_helper"

RSpec.describe GenerateMessagesJob, type: :job do
  include ActiveJob::TestHelper
  
  before do
    ActiveJob::Base.queue_adapter = :test
    @experiment = create(:experiment)
    allow_any_instance_of(Experiment).to receive(:create_messages)
  end
  
  it 'queues the job' do
    expect { GenerateMessagesJob.perform_later(@experiment) }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end
  
  it 'queues the job in the default queue' do
    expect(GenerateMessagesJob.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    expect_any_instance_of(Experiment).to receive(:create_messages)
    
    perform_enqueued_jobs { GenerateMessagesJob.perform_later(@experiment) }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end