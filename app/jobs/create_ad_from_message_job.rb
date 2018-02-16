class CreateAdFromMessageJob < ActiveJob::Base
  queue_as :default
 
  def perform
    @facebook_ads_client = FacebookAdsClient.new('act_115443465928527')
    published_facebook_ads = Message.where(medium: :ad, platform: :facebook, ad_published: nil)
    published_facebook_ads.each do |message|
      @facebook_ads_client.create_ad_set_from_message(message)
      @facebook_ads_client.create_adcreative_from_message(message)
      @facebook_ads_client.create_ad_from_message
      message.set_ad_as_published
    end
    return published_facebook_ads
  end
end