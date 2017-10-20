require "rails_helper"

RSpec.describe CalculateClickAndGoalRateJob, type: :job do
  include ActiveJob::TestHelper

  before do
    ActiveJob::Base.queue_adapter = :test
    experiment = create(:experiment)
    @messages = create_list(:message, 5, message_generating: experiment)
    @messages[0].publish_status = :published_to_buffer
    @messages[1].publish_status = :pending
    (2..4).each do |index|
      @messages[index].publish_status = :published_to_social_network
      @messages[index].save
    end
    @messages.each do |message|
      allow(message).to receive(:calculate_click_rate)
      allow(message).to receive(:calculate_website_goal_rate)
      allow(message).to receive(:calculate_session_count)
      allow(message).to receive(:calculate_goal_count)
    end
    allow(Message).to receive(:where).and_return([@messages[2], @messages[3], @messages[4]])
  end

  it 'queues the job' do
    expect { CalculateClickAndGoalRateJob.perform_later }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'queues the job in the default queue' do
    expect(CalculateClickAndGoalRateJob.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    perform_enqueued_jobs { CalculateClickAndGoalRateJob.perform_later }

    expect(Message).to have_received(:where).with(publish_status: :published_to_social_network)
    (2..4).each do |index|
      expect(@messages[index]).to have_received(:calculate_click_rate)
      expect(@messages[index]).to have_received(:calculate_website_goal_rate)
      expect(@messages[index]).to have_received(:calculate_session_count).with(@messages[index].message_generating.ip_exclusion_list)
      expect(@messages[index]).to have_received(:calculate_goal_count)
    end
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end