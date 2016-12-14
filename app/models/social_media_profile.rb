class SocialMediaProfile < ActiveRecord::Base
  extend Enumerize
  
  validates :service_id, presence: true
  validates :service_username, presence: true
  validates :platform, presence: true
  enumerize :platform, in: [:facebook, :instagram, :twitter]
end
