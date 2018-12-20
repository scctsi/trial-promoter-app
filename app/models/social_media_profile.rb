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
  has_many :messages

  def platform
    return self[:platform].to_sym if !self[:platform].nil?
    nil
  end

  def allowed_mediums
    return symbolize_array_items(self[:allowed_mediums])
  end

  def description
    return ("<i class = '#{platform} icon'></i> #{platform.to_s.titleize} [] #{service_username}").html_safe if allowed_mediums.nil?
    return ("<i class = '#{platform} icon'></i> #{platform.to_s.titleize} [#{allowed_mediums.join(', ').titleize}] #{service_username}").html_safe
  end

  def platform_icon_and_name(size = '')
    return ("<i class = '#{platform} icon #{size}'></i> #{platform.to_s.titleize}").html_safe
  end

  def platform_icon(size = '')
    return ("<i class = '#{platform} icon #{size}'></i>").html_safe
  end
end
