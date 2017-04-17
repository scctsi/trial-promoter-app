# REF: https://medium.com/@chuckjhardy/testing-rails-activejob-with-rspec-5c3de1a64b66#.2cmux4kvm
require "rails_helper"

RSpec.describe CheckValidityForInstagramAdsJob, type: :job do
  include ActiveJob::TestHelper
  
  before do
    ActiveJob::Base.queue_adapter = :test
  end
  
  it 'queues the job' do
    expect { CheckValidityForInstagramAdsJob.perform_later }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end
  
  it 'queues the job in the default queue' do
    expect(CheckValidityForInstagramAdsJob.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    allow(InstagramAdImageRequirementsChecker).to receive(:set_image_sizes)
    allow(InstagramAdImageRequirementsChecker).to receive(:check_image_sizes)
    
    expect(InstagramAdImageRequirementsChecker).to receive(:set_image_sizes)
    expect(InstagramAdImageRequirementsChecker).to receive(:check_image_sizes)

    perform_enqueued_jobs { CheckValidityForInstagramAdsJob.perform_later }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end