require "rails_helper"

RSpec.describe ProcessAnalyticsFilesJob, type: :job do
  include ActiveJob::TestHelper
  
  before do
    @analytics_files = create_list(:analytics_file, 3)
    @analytics_files.each { |analytics_file| allow(analytics_file).to receive(:process) }
  end
  
  it 'queues the job' do
    expect { ProcessAnalyticsFilesJob.perform_later(@experiment) }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end
  
  it 'queues the job in the default queue' do
    expect(ProcessAnalyticsFilesJob.new.queue_name).to eq('default')
  end

  it 'processes each analytics file' do
    @analytics_files.each { |analytics_file| expect(analytics_file).to receive(:process) }

    perform_enqueued_jobs { ProcessAnalyticsFilesJob.perform_later }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end