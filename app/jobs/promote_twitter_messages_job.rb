class PromoteTwitterMessagesJob < ActiveJob::Base
  queue_as :default
 
  def perform
    @twitter_ads_client = TwitterAdsClient.new
    @account = @twitter_ads_client.get_account
    @twitter_ads_client.promote_tweet(@account, line_item_id, tweet_id)
  end
end