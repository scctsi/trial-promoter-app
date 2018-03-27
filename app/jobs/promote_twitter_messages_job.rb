class PromoteTwitterMessagesJob < ActiveJob::Base
  queue_as :default
 
  def perform
    @twitter_ads_client = TwitterAdsClient.new('@USCTrials')
    account_id = '@USCTrials'

    # schedule twitter ads promotion
    #Notes for Alicia to do right now: buffer client status of message should set the real value :published_to_social_network
    twitter_messages = Message.where(platform: :twitter, medium: :ad, publish_status: :pending, social_network_id: nil).where('scheduled_date_time BETWEEN ? AND ?', Time.now, Time.now + 1.month)
    line_item_id = "b0sjz"
    
    twitter_messages.each do |message|
      message.social_network_id = @twitter_ads_client.create_scheduled_tweet(account_id, message)
      
      
      #this has to promote scheduled tweet
      @twitter_ads_client.create_scheduled_promoted_tweet(account_id, line_item_id, message.social_network_id)
      @twitter_ads_client.promote_tweet(account_id, line_item_id, message.social_network_id)
      message.publish_status = :published_to_social_network
      message.save
    end
  end
end