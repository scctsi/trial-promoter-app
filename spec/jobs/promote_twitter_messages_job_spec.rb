require "rails_helper"

RSpec.describe PromoteTwitterMessagesJob, type: :job do
  include ActiveJob::TestHelper
  
  before do
    ActiveJob::Base.queue_adapter = :test
    @twitter_ads_client = double('twitter_ads_client')
    @account = '@USCTrials'
    allow(TwitterAdsClient).to receive(:new).and_return(@twitter_ads_client)
    @line_item_id = 'b0sjz'
    tweet_id = '822248659043520512'
      
    @messages = build_list(:message, 5)
    (0..1).each do |index|
      @messages[index].social_network_id = '822248659043520512'
      @messages[index].medium = :ad
      @messages[index].platform = :twitter
    end
  
    @messages[2].social_network_id = nil
    @messages[2].medium = :ad
    @messages[2].platform = :twitter
    
    @messages[3].social_network_id = nil
    @messages[3].medium = :organic
    @messages[3].platform = :twitter
    
    @messages[4].social_network_id = nil
    @messages[4].medium = :ad
    @messages[4].platform = :facebook
    
    @messages.each do |message|
      message.save
    end
    
    # Set up mocks for promoting tweets
    (0..1).each do |index|
      allow(@twitter_ads_client).to receive(:promote_tweet).with(@account, @line_item_id, @messages[index].social_network_id)
    end
  end

  it 'queues the job' do
    expect { PromoteTwitterMessagesJob.perform_later }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end
  
  it 'queues the job in the default queue' do
    expect(PromoteTwitterMessagesJob.new.queue_name).to eq('default')
  end
  
  #TODO add method to make message attribute :ad_published (from facebook automatic ads branch)
  xit 'saves ad_published to true for the published messages' do
    perform_enqueued_jobs { PromoteTwitterMessagesJob.perform_later(@account) }
  end
  
  it 'promotes messages that are twitter ads which have not been published' do
    (0..1).each do |index|
      expect(@twitter_ads_client).to receive(:promote_tweet).with(@account, @line_item_id, @messages[index].social_network_id)
    end
    
    perform_enqueued_jobs { PromoteTwitterMessagesJob.perform_later(@account) }
  end
    
  it 'does not execute perform on non-twitter message' do
    expect(@twitter_ads_client).not_to receive(:promote_tweet).with(@account, @line_item_id, @messages[2].social_network_id)
    
    perform_enqueued_jobs { PromoteTwitterMessagesJob.perform_later(@account) }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
