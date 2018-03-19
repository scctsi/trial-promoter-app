class PromoteTwitterMessagesJob < ActiveJob::Base
  queue_as :default
 
  def perform(account)
    @twitter_ads_client = TwitterAdsClient.new(account)
    #TODO refactor this to add the method that creates a line item in order to 
    # schedule twitter ads promotion
    line_item_id = "b0sjz"
    tweet_id = '822248659043520512'
    twitter_messages = Message.where(medium: :ad, platform: :twitter).where.not(social_network_id: nil )
    twitter_messages.each do |message|
      next if message.social_network_id.nil?
      tweet_id = message.social_network_id 
      @twitter_ads_client.promote_tweet(account, line_item_id, tweet_id)
    end
  end
end