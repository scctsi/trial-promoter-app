class SocialMediaSpecification < ActiveRecord::Base
  extend Enumerize

  validates :platform, presence: true
  validates :post_type, presence: true
  validates :format, presence: true
  validates :placement, presence: true

  enumerize :platform, in: [:facebook, :google, :twitter]
  enumerize :post_type, in: [:organic, :promoted, :ad]
  enumerize :format, in: [:single_image, :text, :tweet]
  enumerize :placement, in: [:news_feed, :search_network, :timeline]
end
