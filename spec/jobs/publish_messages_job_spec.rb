require "rails_helper"

RSpec.describe PublishMessagesJob, type: :job do
  include ActiveJob::TestHelper
  
  before do
    ActiveJob::Base.queue_adapter = :test
    website = create(:website)
    experiment = create(:experiment)
    @messages = create_list(:message, 10, message_generating: experiment, promotable: website)
    (5..9).each do |index|
      @messages[index].publish_status = :published_to_buffer
      @messages[index].save
    end
    allow(BufferClient).to receive(:create_update)
  end
  
  it 'queues the job' do
    expect { PublishMessagesJob.perform_later(@experiment) }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end
  
  it 'queues the job in the default queue' do
    expect(PublishMessagesJob.new.queue_name).to eq('default')
  end

  it 'executes perform and publishes pending messages' do
    (0..4).each do |index|
      expect(BufferClient).to receive(:create_update).with(@messages[index])
    end
    perform_enqueued_jobs { PublishMessagesJob.perform_later }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end