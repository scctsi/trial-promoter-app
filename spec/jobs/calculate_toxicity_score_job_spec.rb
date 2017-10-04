require "rails_helper"

RSpec.describe CalculateToxicityScoreJob, type: :job do
  include ActiveJob::TestHelper
  
  before do
    ActiveJob::Base.queue_adapter = :test
    allow(PerspectiveClient).to receive(:calculate_toxicity_score)
    @comments = create_list(:comment, 3)
    allow(Comment).to receive(:all).and_return(@comments)
  end
  
  it 'queues the job' do
    expect { CalculateToxicityScoreJob.perform_later(@experiment) }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end
  
  it 'queues the job in the default queue' do
    expect(CalculateToxicityScoreJob.new.queue_name).to eq('default')
  end

  it 'processes each comment toxicity_score' do 
    (0..2).each do |index|
      expect(PerspectiveClient).to receive(:calculate_toxicity_score).with(@comments[index].comment_text)
    end
    
    perform_enqueued_jobs { CalculateToxicityScoreJob.perform_later }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end