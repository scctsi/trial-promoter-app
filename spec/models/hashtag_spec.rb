# == Schema Information
#
# Table name: hashtags
#
#  id         :integer          not null, primary key
#  phrase     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

describe Hashtag do
  it { is_expected.to validate_presence_of :phrase }
  it { is_expected.to validate_uniqueness_of :phrase }
end
