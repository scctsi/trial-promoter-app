class PromoteTwitterMessagesJob < ActiveJob::Base
  queue_as :default
 
  def perform(account, line_item_params = {})
    @twitter_ads_client = TwitterAdsClient.new(account)
    campaign_id = 'ag1g3'
    #TODO refactor this to add the method that creates a line item in order to 
    # schedule twitter ads promotion
    twitter_messages = Message.where(medium: :ad, platform: :twitter).where.not(social_network_id: nil )
    twitter_messages.each do |twitter_message|
      line_item = @twitter_ads_client.create_ad_line_item_from_message(account, campaign_id, line_item_params, message)
    end    
    # line_item_id = "b0sjz"
    
    
    tweet_id = '822248659043520512'
    twitter_messages.each do |message|
      next if message.social_network_id.nil?
      tweet_id = message.social_network_id 
      @twitter_ads_client.promote_tweet(account, line_item.id, tweet_id)
    end
  end
end