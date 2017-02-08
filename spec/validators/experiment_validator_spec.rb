require 'rails_helper'

RSpec.describe ExperimentValidator, type: :validator do
  before do
    @experiment = build(:experiment)
  end

  it 'requires at least one selected social media profile' do
    @experiment.message_generation_parameter_set = build(:message_generation_parameter_set, message_generating: @experiment, :social_network_choices => [:facebook], :medium_choices => ['ad'])

    @experiment.save

    expect(@experiment).not_to be_valid
    expect(@experiment.errors[:social_media_profiles]).to include('requires at least one selection.')
  end

  it 'requires atleast one selected social media profile to match a single required platform' do
    @experiment.message_generation_parameter_set = build(:message_generation_parameter_set, message_generating: @experiment, :social_network_choices => [:facebook], :medium_choices => ['ad'])
    social_media_profile = build(:social_media_profile)
    social_media_profile.platform = 'twitter'
    social_media_profile.allowed_mediums = [:ad]
    @experiment.social_media_profiles << social_media_profile

    @experiment.save

    expect(@experiment).not_to be_valid
    expect(@experiment.errors[:social_media_profiles]).to include('requires at least one selection for Facebook.')
  end

  it 'requires atleast one selected social media platform for each required platform (multiple required platforms)' do
    @experiment.message_generation_parameter_set = build(:message_generation_parameter_set, message_generating: @experiment, :social_network_choices => [:facebook, :instagram], :medium_choices => ['ad'])
    social_media_profile = build(:social_media_profile)
    social_media_profile.platform = 'facebook'
    social_media_profile.allowed_mediums = [:ad]
    @experiment.social_media_profiles << social_media_profile

    @experiment.save

    expect(@experiment).not_to be_valid
    expect(@experiment.errors[:social_media_profiles]).to include('requires at least one selection for Instagram.')
  end

  it 'correctly indicates multiple missing social media platform requirements' do
    @experiment.message_generation_parameter_set = build(:message_generation_parameter_set, message_generating: @experiment, :social_network_choices => [:facebook, :instagram], :medium_choices => ['ad'])
    social_media_profile = build(:social_media_profile)
    social_media_profile.platform = 'twitter'
    social_media_profile.allowed_mediums = [:ad]
    @experiment.social_media_profiles << social_media_profile

    @experiment.save

    expect(@experiment).not_to be_valid
    expect(@experiment.errors[:social_media_profiles]).to include('requires at least one selection for Facebook, Instagram.')
  end

  it 'requires atleast one selected social media profile to allow a single required medium' do
    @experiment.message_generation_parameter_set = build(:message_generation_parameter_set, message_generating: @experiment, :social_network_choices => [:facebook], :medium_choices => ['ad'])
    social_media_profile = build(:social_media_profile)
    social_media_profile.platform = 'facebook'
    social_media_profile.allowed_mediums = [:organic]
    @experiment.social_media_profiles << social_media_profile

    @experiment.save

    expect(@experiment).not_to be_valid
    expect(@experiment.errors[:social_media_profiles]).to include('requires at least one selection for Facebook [Ad].')
  end

  it 'requires at least one selected social media profile of the correct platform to allow a single required medium on a platform' do
    @experiment.message_generation_parameter_set = build(:message_generation_parameter_set, message_generating: @experiment, :social_network_choices => [:facebook], :medium_choices => ['ad'])
    social_media_profile = build(:social_media_profile)
    social_media_profile.platform = 'facebook'
    social_media_profile.allowed_mediums = [:organic]
    @experiment.social_media_profiles << social_media_profile
    social_media_profile = build(:social_media_profile)
    social_media_profile.platform = 'instagram'
    social_media_profile.allowed_mediums = [:ad]
    @experiment.social_media_profiles << social_media_profile

    @experiment.save

    expect(@experiment).not_to be_valid
    expect(@experiment.errors[:social_media_profiles]).to include('requires at least one selection for Facebook [Ad].')
  end

  it "ignores a requirement for Instagram [Organic]" do
    experiment = build(:experiment)
    experiment.message_generation_parameter_set = build(:message_generation_parameter_set, message_generating: experiment, :social_network_choices => [:instagram],
    :medium_choices => ['organic'])
    posting_times = [Time.new(2017, 01, 01, 0, 0, 0, "+00:00")]
    experiment.posting_times = posting_times
    social_media_profile = build(:social_media_profile)
    social_media_profile.platform = 'instagram'
    social_media_profile.allowed_mediums = [:ad]
    experiment.social_media_profiles << social_media_profile

    experiment.save
    expect(experiment).to be_valid
  end

  describe 'posting times validations' do
    before do
      @experiment.message_generation_parameter_set = build(:message_generation_parameter_set, :number_of_messages_per_social_network => 3, :message_generating => @experiment)
      @experiment.social_media_profiles << build(:social_media_profile, :platform => 'facebook', :allowed_mediums => ['ad'])
    end

    it 'rejects posting times if it is less than the number of messages per social network per day' do

      #make sure numbers match - count of posting_times per day matches the number of MGPS.number_of_messages_per_social_network
      posting_times = [Time.new(2017, 01, 01, 0, 0, 0, "+00:00"), Time.new(2017, 01, 01, 0, 0, 0, "+00:00")]
      @experiment.posting_times = posting_times

      @experiment.save

      expect(@experiment).not_to be_valid

    end

    it 'rejects posting times if it is more than the number of messages per social network per day' do

      #make sure numbers match - count of posting_times per day matches the number of MGPS.number_of_messages_per_social_network
      posting_times = [Time.new(2017, 01, 01, 0, 0, 0, "+00:00"), Time.new(2017, 01, 01, 0, 0, 0, "+00:00"), Time.new(2017, 01, 01, 0, 0, 0, "+00:00"), Time.new(2017, 01, 01, 0, 0, 0, "+00:00")]
      @experiment.posting_times = posting_times

      @experiment.save

      expect(@experiment).not_to be_valid
    end

    it 'rejects posting times if there are no posting times selected' do
      @experiment.posting_times = []

      @experiment.save

      expect(@experiment).not_to be_valid
    end
  end
end

