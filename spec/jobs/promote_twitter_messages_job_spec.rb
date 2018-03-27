require "rails_helper"

RSpec.describe PromoteTwitterMessagesJob, type: :job do
  include ActiveJob::TestHelper
  
  before do
    ActiveJob::Base.queue_adapter = :test
    @twitter_ads_client = double('twitter_ads_client')
    @account = '@USCTrials'
    @campaign_id = 'ag1g3'
    allow(TwitterAdsClient).to receive(:new).and_return(@twitter_ads_client)
    @line_item_params = {
      name: 'my first objective',
      product_type: 'PROMOTED_TWEETS',
      placements: 'ALL_ON_TWITTER',
      objective: 'AWARENESS',
      bid_type: 'AUTO',
      entity_status: 'PAUSED'
    }
    @line_item_id = "b0sjz"
    @tweet_id = '822248659043520512'
      
    @messages = create_list(:message, 6)
    @messages[0].social_network_id = nil
    @messages[0].medium = :ad
    @messages[0].platform = :twitter
    @messages[0].publish_status = :pending
    @messages[0].scheduled_date_time = Time.now + 1.month

    @messages[1].scheduled_date_time = Time.now - 1.month
    @messages[2].platform = :facebook
    @messages[2].social_network_id = '822248659043520512'
    @messages[3].publish_status = :published_to_social_network
    @messages[4].social_network_id = nil
    @messages[4].medium = :ad
    @messages[4].platform = :facebook
    @messages[4].publish_status = :pending
    
    @messages[5].scheduled_date_time = Time.now - 1.day
    @messages[5].social_network_id = '822248659043520512'
    @messages[5].medium = :ad
    @messages[5].platform = :twitter
    @messages[5].publish_status = :pending
    
    @messages.each do |message|
      message.save
    end
    
    allow(@twitter_ads_client).to receive(:create_scheduled_tweet).with(@account, @messages[0]).and_return(@tweet_id)
    allow(@twitter_ads_client).to receive(:create_scheduled_promoted_tweet).with(@account, @line_item_id, @tweet_id)
    allow(@twitter_ads_client).to receive(:promote_tweet).with(@account, @line_item_id, @tweet_id)
  end

  it 'queues the job' do
    expect { PromoteTwitterMessagesJob.perform_later(@account) }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end
  
  it 'queues the job in the default queue' do
    expect(PromoteTwitterMessagesJob.new.queue_name).to eq('default')
  end
  
  it 'promotes messages that are twitter ads which are scheduled to be published to Twitter in the next month' do
    expect(@twitter_ads_client).to receive(:promote_tweet).with(@account, @line_item_id, @tweet_id)
    expect(@twitter_ads_client).not_to receive(:promote_tweet).with(@account, @line_item_id, @messages[1].social_network_id)
    expect(@twitter_ads_client).not_to receive(:promote_tweet).with(@account, @line_item_id, @messages[2].social_network_id)
    
    perform_enqueued_jobs { PromoteTwitterMessagesJob.perform_later }
  end
    
  it 'does not execute perform on non-twitter message' do
    expect(@twitter_ads_client).not_to receive(:create_scheduled_tweet).with(@account, @line_item_id, @messages[2].social_network_id)
    expect(@twitter_ads_client).not_to receive(:create_scheduled_tweet).with(@account, @line_item_id, @messages[4].social_network_id)
    expect(@twitter_ads_client).not_to receive(:create_scheduled_tweet).with(@account, @line_item_id, @messages[5].social_network_id)
    
    perform_enqueued_jobs { PromoteTwitterMessagesJob.perform_later }
  end
    
  it 'does not execute perform on an already published message' do
    expect(@twitter_ads_client).not_to receive(:create_scheduled_promoted_tweet).with(@account, @line_item_id, @messages[3].social_network_id)
    
    perform_enqueued_jobs { PromoteTwitterMessagesJob.perform_later }
  end

  it 'saves the publish status as published to social network for the published messages' do
    perform_enqueued_jobs { PromoteTwitterMessagesJob.perform_later }
    
    @messages.each{ |message| message.reload }
     
    expect(@messages[0].publish_status).to eq(:published_to_social_network)
    (1..2).each do |index|
      expect(@messages[index].publish_status).to eq(:pending)
    end
    expect(@messages[3].publish_status).to eq(:published_to_social_network)
    (4..5).each do |index|
      expect(@messages[index].publish_status).to eq(:pending)
    end
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
