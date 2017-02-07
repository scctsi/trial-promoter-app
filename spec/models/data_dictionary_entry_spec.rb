require 'rails_helper'

RSpec.describe DataDictionaryEntry do
  it { is_expected.to validate_presence_of :trial_promoter_label }
  it { is_expected.to validate_presence_of(:source) }
  it { is_expected.to enumerize(:source).in(:buffer, :twitter, :facebook, :instagram, :google_analytics) }
  it { is_expected.to belong_to(:data_dictionary) }
  it { is_expected.to validate_presence_of(:data_dictionary) }
end
