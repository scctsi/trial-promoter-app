require "rails_helper"

RSpec.describe GetUpdatesFromBufferJob, type: :job do
  include ActiveJob::TestHelper
  
  before do
    ActiveJob::Base.queue_adapter = :test
    allow(BufferClient).to receive(:get_update)
    experiment = create(:experiment)
    @messages = create_list(:message, 10, message_generating: experiment)
    (0..4).each do |index|
      @messages[index].publish_status = :pending
      @messages[index].scheduled_date_time = Time.now + 1.day
      @messages[index].buffer_update
      @messages[index].save
    end
    (5..9).each do |index|
      @messages[index].publish_status = :published_to_buffer
      @messages[index].scheduled_date_time = Time.now + 30.days
      @messages[index].buffer_update = build(:buffer_update, message: @messages[index])
      @messages[index].buffer_update.save
      @messages[index].save
    end
    (5..7).each do |index|
      @messages[index].buffer_update.status = :sent
      @messages[index].buffer_update.save
      @messages[index].save
    end
  end
  
  it 'queues the job' do
    expect { GetUpdatesFromBufferJob.perform_later(@experiment) }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end
  
  it 'queues the job in the default queue' do
    expect(GetUpdatesFromBufferJob.new.queue_name).to eq('default')
  end

  it 'executes perform and gets update for only Buffer updates that are currently pending' do
    (8..9).each do |index|
      expect(BufferClient).to receive(:get_update).with(@experiment, @messages[index])
    end

    perform_enqueued_jobs { GetUpdatesFromBufferJob.perform_later(@experiment) }
  end

  it 'throttles the job to 1 request per second (based on Buffer rate limits)' do
    (8..9).each do |index|
      expect(Throttler).to receive(:throttle).with(1)
    end

    perform_enqueued_jobs { GetUpdatesFromBufferJob.perform_later(@experiment) }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end