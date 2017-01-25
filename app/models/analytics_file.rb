# == Schema Information
#
# Table name: analytics_files
#
#  id                      :integer          not null, primary key
#  url                     :string(2000)
#  original_filename       :string
#  social_media_profile_id :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class AnalyticsFile < ActiveRecord::Base
  validates :social_media_profile, presence: true
  validates :required_upload_date, presence: true
  validates :message_generating, presence: true

  belongs_to :social_media_profile
  belongs_to :message_generating, polymorphic: true
end
