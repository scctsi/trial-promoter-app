# == Schema Information
#
# Table name: social_media_profiles
#
#  id               :integer          not null, primary key
#  platform         :string
#  service_id       :string
#  service_type     :string
#  service_username :string
#  buffer_id        :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  allowed_mediums  :string
#

class SocialMediaProfile < ActiveRecord::Base
  extend Enumerize
  
  serialize :allowed_mediums
  
  validates :service_id, presence: true
  validates :service_username, presence: true
  validates :platform, presence: true
  enumerize :platform, in: [:facebook, :instagram, :twitter]
  has_and_belongs_to_many :experiments
  has_many :analytics_files

  def allowed_mediums
    return symbolize_array_items(self[:allowed_mediums])
  end
end
