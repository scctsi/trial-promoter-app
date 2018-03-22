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
    @line_item = '{"data":{"bid_type":"AUTO","advertiser_user_id":3194630402,"name":"my
        other objective","placements":["ALL_ON_TWITTER"],"start_time":null,"bid_amount_local_micro":null,"automatically_select_bid":true,"advertiser_domain":null,"target_cpa_local_micro":null,"primary_web_event_tag":null,"charge_by":"IMPRESSION","product_type":"PROMOTED_TWEETS","end_time":null,"bid_unit":"VIEW","total_budget_amount_local_micro":null,"objective":"AWARENESS","id":"ekzp","entity_status":"ACTIVE","account_id":"gq1azc","optimization":"DEFAULT","categories":[],"currency":"USD","created_at":"2018-02-27T02:01:14Z","tracking_tags":[],"updated_at":"2018-02-27T02:01:14Z","include_sentiment":"POSITIVE_ONLY","campaign_id":"hppy","creative_source":"MANUAL","deleted":false},"request":{"params":{"bid_type":"AUTO","name":"my
        other objective","placements":["ALL_ON_TWITTER"],"product_type":"PROMOTED_TWEETS","objective":"AWARENESS","entity_status":"ACTIVE","account_id":"gq1azc","campaign_id":"hppy"}}}'
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
      allow(@twitter_ads_client).to receive(:create_ad_line_item_from_message).with(@account, @campaign_id, @line_item_params, @messages[index]).and_return(@line_item)
      allow(@twitter_ads_client).to receive(:get_ad_line_item).with(@account, @line_item_id).and_return(@line_item)
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
      expect(@twitter_ads_client).to receive(:create_ad_line_item).with(@account, @campaign_id, @line_item_params)
    end
    
    perform_enqueued_jobs { PromoteTwitterMessagesJob.perform_later(@account, @line_item_params) }
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
