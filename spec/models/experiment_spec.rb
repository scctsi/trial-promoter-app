# == Schema Information
#
# Table name: experiments
#
#  id                              :integer          not null, primary key
#  name                            :string(1000)
#  start_date                      :datetime
#  end_date                        :datetime
#  message_distribution_start_date :datetime
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

require 'rails_helper'

RSpec.describe Experiment, type: :model do
  before do
    time_now = Time.new(2017, 01, 01, 0, 0, 0, "+00:00")
    allow(Time).to receive(:now).and_return(time_now)
  end

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :start_date }
  it { is_expected.to validate_presence_of :end_date }

  it { is_expected.to have_one(:message_generation_parameter_set) }
  it { is_expected.to accept_nested_attributes_for(:message_generation_parameter_set) }
  it { is_expected.to have_many(:messages) }
  it { is_expected.to have_many(:analytics_files) }
  it { is_expected.to have_and_belong_to_many :social_media_profiles }

  it 'disables message generation when distribution start date is less than 24 hours from current time' do
    experiment = create(:experiment, message_distribution_start_date: Time.new(2017, 01, 01, 23, 59, 0,  "+00:00") )

    expect(experiment.disable_message_generation?).to be true
  end

  it 'does not disable message generation when distribution start date is more than 24 hours from current time' do
    experiment = create(:experiment, message_distribution_start_date: Time.new(2017, 01, 03, 0, 0, 0, "+00:00") )

    expect(experiment.disable_message_generation?).to be false
  end

  it 'will not determine whether to disable message generation when distribution start date is not present' do
    experiment = create(:experiment)

    expect(experiment.disable_message_generation?).to be false
  end

  it 'parameterizes id and name together' do
    experiment = create(:experiment, name: 'TCORS 2')

    expect(experiment.to_param).to eq("#{experiment.id}-#{experiment.name.parameterize}")
  end

  it 'creates messages using a message factory' do
    experiment = build(:experiment)
    allow(experiment).to receive(:create_messages).and_call_original
    message_factory = MessageFactory.new(TagMatcher.new, SocialMediaProfilePicker.new)
    allow(message_factory).to receive(:create).with(experiment)
    allow(MessageFactory).to receive(:new).and_return(message_factory)

    experiment.create_messages

    expect(MessageFactory).to have_received(:new)
    expect(message_factory).to have_received(:create).with(experiment)
  end

  it 'iterates over all the days in the experiment' do
    experiment = build(:experiment, start_date: Time.new(2017, 01, 01, 0, 0, 0, "+00:00"), end_date: Time.new(2017, 01, 02, 0, 0, 0, "+00:00"))
    number_of_days = 0

    experiment.each_day do |day|
      expect(day).to be >= experiment.start_date
      expect(day).to be <= experiment.end_date
      number_of_days += 1
    end
    expect(number_of_days).to eq((experiment.end_date - experiment.start_date).to_i / (24 * 60 * 60) + 1)
  end

  it 'requires at least one social media profile to be selected' do
    experiment = build(:experiment)
    experiment.message_generation_parameter_set = build(:message_generation_parameter_set, message_generating: experiment, :social_network_choices => [:facebook],
      :medium_choices => ['ad'])
    experiment.social_media_profiles = []

    experiment.save

    expect(experiment).to_not be_valid
    expect(experiment.errors[:social_media_profiles]).to include('requires at least one selected social media profile.')
  end

  it 'requires that the required platform is in the selected social media profiles' do
    experiment = build(:experiment)
    experiment.message_generation_parameter_set = build(:message_generation_parameter_set, message_generating: experiment, :social_network_choices => [:facebook],
    :medium_choices => ['ad'])
    social_media_profile = build(:social_media_profile)
    social_media_profile.platform = 'twitter'
    social_media_profile.allowed_mediums = [:ad, :organic]
    experiment.social_media_profiles = []
    experiment.social_media_profiles << social_media_profile

    experiment.save

    expect(experiment).to_not be_valid
    expect(experiment.errors[:social_media_profiles]).to include('requires social media platform(s) to match the selected social media profile.')
  end

  it 'requires that the required medium is in the selected social media profiles' do
    experiment = build(:experiment)
    experiment.message_generation_parameter_set = build(:message_generation_parameter_set, message_generating: experiment, :social_network_choices => [:facebook],
    :medium_choices => ['ad'])
    social_media_profile = build(:social_media_profile, platform: 'facebook', allowed_mediums: [:organic])
    experiment.social_media_profiles = []
    experiment.social_media_profiles << social_media_profile

    experiment.save

    expect(experiment).to_not be_valid
    expect(experiment.errors[:social_media_profiles]).to include('requires social media medium(s) to match the selected social media profile.')
  end

  it 'ignores medium validation if a social media profile has nil allowed mediums' do
    experiment = build(:experiment)
    experiment.message_generation_parameter_set = build(:message_generation_parameter_set, message_generating: experiment, :social_network_choices => [:facebook],
    :medium_choices => ['ad'])
    social_media_profile = build(:social_media_profile, platform: 'facebook', allowed_mediums: nil)
    experiment.social_media_profiles = []
    experiment.social_media_profiles << social_media_profile

    experiment.save

    expect(experiment).to be_valid
  end

  xit "ignores the validation of selecting the medium 'organic' for Instagram" do
    experiment = build(:experiment)
    experiment.message_generation_parameter_set = build(:message_generation_parameter_set, message_generating: experiment, :social_network_choices => [:instagram],
    :medium_choices => ['organic'])
    social_media_profile = build(:social_media_profile)
    social_media_profile.platform = 'instagram'
    social_media_profile.allowed_mediums = [:ad]
    experiment.social_media_profiles << social_media_profile

    experiment.save
    expect(experiment).to be_valid
  end

  describe 'creating a todo list for analytics uploads' do
    before do
      @social_media_profiles = create_list(:social_media_profile, 4)
      @social_media_profiles[0].platform = :twitter
      @social_media_profiles[0].allowed_mediums = [:ad]
      @social_media_profiles[1].platform = :twitter
      @social_media_profiles[1].allowed_mediums = [:organic]
      @social_media_profiles[2].platform = :facebook
      @social_media_profiles[2].allowed_mediums = [:ad]
      @social_media_profiles[3].platform = :facebook
      @social_media_profiles[3].allowed_mediums = [:organic]
      @social_media_profiles.each { |social_media_profile| social_media_profile.save }
    end

    it 'retrieves a list of all associated social media profiles that need analytics uploads' do
      experiment = build(:experiment)
      @social_media_profiles.each { |social_media_profile| experiment.social_media_profiles << social_media_profile }
      experiment.save

      profiles = experiment.social_media_profiles_needing_analytics_uploads

      expect(profiles.count).to eq(2)
      profiles.each { |profile| expect(profile.platform) == :twitter }
    end

    it 'does not create todos if no social media profiles require analytics uploads' do
      experiment = build(:experiment)
      experiment.social_media_profiles << @social_media_profiles[2]
      experiment.save

      experiment.create_analytics_file_todos

      expect(AnalyticsFile.count).to eq(0)
      expect(experiment.analytics_file_todos_created).to be true
    end

    it 'creates todos (one for each day and social media profile) if any social media profiles require analytics uploads' do
      experiment = build(:experiment, start_date: Time.new(2017, 01, 01, 0, 0, 0, "+00:00"), end_date: Time.new(2017, 01, 02, 0, 0, 0, "+00:00"))
      experiment.social_media_profiles << @social_media_profiles[0]
      experiment.social_media_profiles << @social_media_profiles[1]
      experiment.save

      experiment.create_analytics_file_todos

      analytics_files = AnalyticsFile.all
      expect(analytics_files.count).to eq(4)
      analytics_files.each { |analytics_file| expect(analytics_file.message_generating).to eq(experiment)}
      expect(analytics_files[0].social_media_profile).to eq(@social_media_profiles[0])
      expect(analytics_files[0].required_upload_date).to eq(experiment.start_date)
      expect(analytics_files[1].social_media_profile).to eq(@social_media_profiles[1])
      expect(analytics_files[1].required_upload_date).to eq(experiment.start_date)
      expect(analytics_files[2].social_media_profile).to eq(@social_media_profiles[0])
      expect(analytics_files[2].required_upload_date).to eq(experiment.end_date)
      expect(analytics_files[3].social_media_profile).to eq(@social_media_profiles[1])
      expect(analytics_files[3].required_upload_date).to eq(experiment.end_date)
      expect(experiment.analytics_file_todos_created).to be true
    end
  end
end
