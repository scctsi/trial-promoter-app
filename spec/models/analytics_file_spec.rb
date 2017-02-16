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
#



require 'rails_helper'

RSpec.describe AnalyticsFile do
  it { is_expected.to validate_presence_of :social_media_profile }
  it { is_expected.to validate_presence_of :required_upload_date }
  it { is_expected.to validate_presence_of :message_generating }
  it { is_expected.to belong_to :social_media_profile }
  it { is_expected.to belong_to :message_generating }
end
