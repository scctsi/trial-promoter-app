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

require 'rails_helper'

RSpec.describe SocialMediaProfile, type: :model do
  it { is_expected.to validate_presence_of :platform }
  it { is_expected.to enumerize(:platform).in(:twitter, :facebook, :instagram) }
  it { is_expected.to validate_presence_of :service_username }
  it { is_expected.to validate_presence_of :service_id }
  it { is_expected.to have_and_belong_to_many :experiments }
  it { is_expected.to have_many :analytics_files }
  it { is_expected.to have_many :messages }

  it 'returns the platform as a symbol' do
    social_media_profile = create(:social_media_profile, platform: 'twitter')

    expect(social_media_profile.platform).to be(:twitter)
  end

  it 'returns the description of the profile' do
    social_media_profile = create(:social_media_profile, service_username: 'USCTrials', platform: 'twitter', allowed_mediums: [:ad, :organic])

p social_media_profile.description
    expect(social_media_profile.description).to match('USCTrials')
    expect(social_media_profile.description).to match('Twitter')
    expect(social_media_profile.description).to match('[Ad, Organic]')
    expect(social_media_profile.description).to match('.twitter.icon')
  end

  it 'stores an array of allowed mediums' do
    social_media_profile = build(:social_media_profile)
    social_media_profile.allowed_mediums = [:ad, :organic]

    social_media_profile.save
    social_media_profile.reload

    expect(social_media_profile.allowed_mediums).to eq([:ad, :organic])
  end

  it 'returns allowed mediums as symbols' do
    social_media_profile = build(:social_media_profile)
    social_media_profile.allowed_mediums = ['ad', 'organic']

    social_media_profile.save
    social_media_profile.reload

    expect(social_media_profile.allowed_mediums).to eq([:ad, :organic])
  end
end
