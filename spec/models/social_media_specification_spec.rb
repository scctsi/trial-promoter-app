require 'rails_helper'

RSpec.describe SocialMediaSpecification, type: :model do
  it { is_expected.to validate_presence_of :platform }
  it { is_expected.to validate_presence_of :post_type }
  it { is_expected.to validate_presence_of :format }
  it { is_expected.to validate_presence_of :placement }
  it { is_expected.to enumerize(:platform).in(:facebook, :google, :twitter) }
  it { is_expected.to enumerize(:post_type).in(:organic, :promoted, :ad) }
  it { is_expected.to enumerize(:format).in(:single_image, :text, :tweet) }
  it { is_expected.to enumerize(:placement).in(:news_feed, :search_network, :timeline) }
end