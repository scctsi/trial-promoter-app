class CreateAdFromMessageJob < ActiveJob::Base
  queue_as :default
 
  def perform
    @facebook_ads_client = FacebookAdsClient.new('act_115443465928527')
    @campaign_id = "120330000027414503"
    published_facebook_ads = Message.where(medium: :ad, platform: :facebook, ad_published: nil)
    published_facebook_ads.each do |message|
      ad_set = @facebook_ads_client.create_ad_set_from_message(@campaign_id, message)
      ad_creative = @facebook_ads_client.create_ad_creative_from_message(message)
      @facebook_ads_client.create_ad_from_ad_creative_and_ad_set(ad_creative.id, ad_set.id)
      message.set_ad_as_published
    end
    return published_facebook_ads
  end
end