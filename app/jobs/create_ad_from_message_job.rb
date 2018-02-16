class CreateAdFromMessageJob < ActiveJob::Base
  queue_as :default
 
  def perform
    @facebook_ads_client = FacebookAdsClient.new('act_115443465928527')
    published_facebook_ads = Message.where(medium: :ad, platform: :facebook, ad_published: nil)
    creative_id = 120330000026551103 
    ad_set_id = "120330000026551503"
    published_facebook_ads.each do |message|
      @facebook_ads_client.create_ad_set_from_message(message)
      @facebook_ads_client.create_adcreative_from_message(message)
      @facebook_ads_client.create_ad_from_message(creative_id, ad_set_id)
      message.set_ad_as_published
    end
    return published_facebook_ads
  end
end