class SocialProfile < ActiveRecord::Base
  validates :network_name, presence: true
  validates :username, presence: true
end