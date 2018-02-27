require "rails_helper"

RSpec.describe PromoteTwitterMessagesJob, type: :job do
  include ActiveJob::TestHelper
  
  before do
    ActiveJob::Base.queue_adapter = :test
    @twitter_ads_client = TwitterAdsClient.new('')
    allow(TwitterAdsClient).to receive(:new).and_return(@twitter_ads_client)
    @campaign_id = "ac5vs"
      
    @messages = build_list(:message, 5)
    (0..1).each do |index|
      @messages[index].social_network_id = '822248659043520512'
      @messages[index].medium = :ad
      @messages[index].platform = :twitter
    end
  
  
    @messages[2].ad_published = nil
    @messages[2].medium = :ad
    @messages[2].platform = :twitter
    
    @messages[3].ad_published = nil
    @messages[3].medium = :organic
    @messages[3].platform = :facebook
    
    @messages[4].ad_published = true
    @messages[4].medium = :organic
    @messages[4].platform = :facebook
    
    @ad_creatives = [OpenStruct.new, OpenStruct.new]
    @ad_creatives[0].id = "1001"
    @ad_creatives[1].id = "1002"
    @ad_sets = [OpenStruct.new, OpenStruct.new]
    @ad_sets[0].id = "2001"
    @ad_sets[1].id = "2002"
    
    @messages.each do |message|
      message.save
    end
  end

  it 'queues the job' do
    expect { PromoteTwitterMessagesJob.perform_later }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end
  
  it 'queues the job in the default queue' do
    expect(PromoteTwitterMessagesJob.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    perform_enqueued_jobs { PromoteTwitterMessagesJob.perform_later }
  end

  it 'saves ad_published to true for the published messages' do
    perform_enqueued_jobs { PromoteTwitterMessagesJob.perform_later }
  end
  
  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
