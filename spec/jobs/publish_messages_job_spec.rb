require "rails_helper"

RSpec.describe PublishMessagesJob, type: :job do
  include ActiveJob::TestHelper
  
  before do
    allow(Time).to receive(:now).and_return(Time.new(2010, 1, 1, 0, 0, 0))    
    allow(BufferClient).to receive(:create_update)
    ActiveJob::Base.queue_adapter = :test
    experiment = create(:experiment)
    @messages = create_list(:message, 10, message_generating: experiment)
    (0..4).each do |index|
      @messages[index].publish_status = :pending
      @messages[index].scheduled_date_time = Time.now + 1.day
      @messages[index].save
    end
    (5..9).each do |index|
      @messages[index].publish_status = :published_to_buffer
      @messages[index].scheduled_date_time = Time.now + 30.days
      @messages[index].save
    end
  end
  
  it 'queues the job' do
    expect { PublishMessagesJob.perform_later(@experiment) }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end
  
  it 'queues the job in the default queue' do
    expect(PublishMessagesJob.new.queue_name).to eq('default')
  end

  it 'executes perform and publishes pending messages' do
    (0..4).each do |index|
      expect(BufferClient).to receive(:create_update).with(@experiment, @messages[index])
    end

    perform_enqueued_jobs { PublishMessagesJob.perform_later(@experiment) }
  end

  it 'throttles the job to 1 request per second (based on Buffer rate limits)' do
    (0..4).each do |index|
      expect(Throttler).to receive(:throttle).with(1)
    end

    perform_enqueued_jobs { PublishMessagesJob.perform_later(@experiment) }
  end

  it 'executes perform and publishes pending messages except organic Instagram messages' do
    # There is currently no way to track organic Instagram messages, so these messages are currently never published to Buffer.
    @messages[0].medium = :organic
    @messages[0].platform = :instagram
    @messages[0].message_template.save
    @messages[0].save

    expect(BufferClient).not_to receive(:create_update).with(@experiment, @messages[0])
    (1..4).each do |index|
      expect(BufferClient).to receive(:create_update).with(@experiment, @messages[index])
    end

    perform_enqueued_jobs { PublishMessagesJob.perform_later(@experiment) }
  end

  it 'executes perform and publishes pending messages that need to be published to social networks in the next 7 days (by default)' do
    @messages[0].scheduled_date_time = Time.new(2010, 1, 1, 0, 0, 0)
    @messages[1].scheduled_date_time = Time.new(2010, 1, 6, 0, 0, 0)
    @messages[2].scheduled_date_time = Time.new(2010, 1, 8, 0, 0, 0)
    @messages[3].scheduled_date_time = Time.new(2010, 1, 9, 0, 0, 0)
    @messages[4].scheduled_date_time = Time.new(2010, 1, 10, 0, 0, 0)
    (0..4).each { |index| @messages[index].save }

    # Only publish pending messages to Buffer up to a week in advance (social_network_publish_date <= 7 days from today)
    (0..2).each do |index|
      expect(BufferClient).to receive(:create_update).with(@experiment, @messages[index])
    end
    # Ignore pending messages that are scheduled more than a week ahead
    (3..4).each do |index|
      expect(BufferClient).not_to receive(:create_update).with(@experiment, @messages[index])
    end

    perform_enqueued_jobs { PublishMessagesJob.perform_later(@experiment) }
  end

  it 'executes perform and publishes pending messages that need to be published to social networks in the next day (by specifying 1 as a parameter to the job)' do
    @messages[0].scheduled_date_time = Time.new(2010, 1, 1, 0, 0, 0)
    @messages[1].scheduled_date_time = Time.new(2010, 1, 6, 0, 0, 0)
    @messages[2].scheduled_date_time = Time.new(2010, 1, 8, 0, 0, 0)
    @messages[3].scheduled_date_time = Time.new(2010, 1, 9, 0, 0, 0)
    @messages[4].scheduled_date_time = Time.new(2010, 1, 10, 0, 0, 0)
    (0..4).each { |index| @messages[index].save }

    # Only publish pending messages to Buffer up to a day in advance (social_network_publish_date <= 1 day from today)
    expect(BufferClient).to receive(:create_update).with(@experiment, @messages[0])
    # Ignore pending messages that are scheduled more than a day ahead
    (1..4).each do |index|
      expect(BufferClient).not_to receive(:create_update).with(@experiment, @messages[index])
    end

    perform_enqueued_jobs { PublishMessagesJob.perform_later(@experiment, 1) }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end