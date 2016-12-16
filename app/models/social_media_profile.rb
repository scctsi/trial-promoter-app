class SocialMediaProfile < ActiveRecord::Base
  extend Enumerize
  
  validates :service_id, presence: true
  validates :service_username, presence: true
  validates :platform, presence: true
  enumerize :platform, in: [:facebook, :instagram, :twitter]
  has_and_belongs_to_many :experiments
end
