FactoryGirl.define do
  factory :social_media_specification do
    platform :facebook
    post_type :ad
    format :single_image
    placement :news_feed
  end
end