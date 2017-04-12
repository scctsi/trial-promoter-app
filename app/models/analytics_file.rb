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
#  required_upload_date    :datetime
#  message_generating_id   :integer
#  message_generating_type :string
#  processing_status       :string
#

class AnalyticsFile < ActiveRecord::Base
  extend Enumerize

  validates :social_media_profile, presence: true
  validates :required_upload_date, presence: true
  validates :message_generating, presence: true
  enumerize :processing_status, in: [:unprocessed, :processed], default: :unprocessed

  belongs_to :social_media_profile
  belongs_to :message_generating, polymorphic: true
  
  def process
    return if processing_status == :processed
    
    csv_content = CsvFileReader.read(url)
    parseable_data = AnalyticsDataParser.convert_to_parseable_data(csv_content, social_media_profile.platform, social_media_profile.allowed_mediums[0])
    parsed_data = AnalyticsDataParser.parse(parseable_data)
    AnalyticsDataParser.store(parsed_data, social_media_profile.platform)
    self.processing_status = :processed
    save
  end
end
