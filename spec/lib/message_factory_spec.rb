require 'rails_helper'

RSpec.describe MessageFactory do
  before do
    @experiment = create(:experiment)
    @suitable_social_media_profiles = create_list(:social_media_profile, 3)
    @suitable_social_media_profiles.each { |social_media_profile| @experiment.social_media_profiles << social_media_profile }
    @experiment.save
    tag_lists = [['tag-1'], ['tag-4', 'tag-5', 'tag-6'], ['tag-2', 'tag-3', 'tag-4']]
    TrialPromoter::SUPPORTED_NETWORKS.each do |social_network|
      # Randomly tag each message template with a set of tags taken from tag_lists
      create_list(:message_template, 5, platform: social_network, experiment_list: @experiment.to_param, tag_list: tag_lists.sample)
    end
    # Set up tag matching
    @tag_matcher = TagMatcher.new
    @image_sets_matching_tag_sets = [create_list(:image, 1), create_list(:image, 2), create_list(:image, 1)]
    allow(@tag_matcher).to receive(:match).with(Image, tag_lists[0]).and_return(@image_sets_matching_tag_sets[0])
    allow(@tag_matcher).to receive(:match).with(Image, tag_lists[1]).and_return(@image_sets_matching_tag_sets[1])
    allow(@tag_matcher).to receive(:match).with(Image, tag_lists[2]).and_return(@image_sets_matching_tag_sets[2])
    @website_sets_matching_tag_sets = [create_list(:website, 2), create_list(:website, 1), create_list(:website, 3)]
    allow(@tag_matcher).to receive(:match).with(Website, tag_lists[0]).and_return(@website_sets_matching_tag_sets[0])
    allow(@tag_matcher).to receive(:match).with(Website, tag_lists[1]).and_return(@website_sets_matching_tag_sets[1])
    allow(@tag_matcher).to receive(:match).with(Website, tag_lists[2]).and_return(@website_sets_matching_tag_sets[2])
    # Set up social media profile picking
    @social_media_profile_picker = SocialMediaProfilePicker.new
    allow(@social_media_profile_picker).to receive(:pick).with(@suitable_social_media_profiles, Message).and_return(@suitable_social_media_profiles[1])
    @message_factory = MessageFactory.new(@tag_matcher, @social_media_profile_picker)
  end

  it 'can be initialized with a tag matcher and a social media profile picker' do
    @message_factory = MessageFactory.new(@tag_matcher, @social_media_profile_picker)
    
    expect(@message_factory.tag_matcher).to eq(@tag_matcher)
    expect(@message_factory.social_media_profile_picker).to eq(@social_media_profile_picker)
  end
  
  it 'creates a set of messages for one website, five message templates, 1 social network (equal distribution), 1 medium (equal distribution), with images (equal distribution), for 10 days and 3 messages per network per day' do
    message_generation_parameter_set = MessageGenerationParameterSet.new do |m|
      m.social_network_choices = [:facebook]
      m.social_network_distribution = :equal
      m.medium_choices = ['ad']
      m.medium_distribution = :equal
      m.image_present_choices = ['with']
      m.image_present_distribution = :equal
      m.period_in_days = 10
      m.number_of_messages_per_social_network = 3
    end
    @experiment.message_generation_parameter_set = message_generation_parameter_set

    @message_factory.create(@experiment)
    
    messages = Message.all
    expect(messages.count).to eq(message_generation_parameter_set.expected_generated_message_count)
    expect((messages.select { |message| message.message_template.platform != :facebook }).count).to eq(0)
  end

  it 'creates a set of messages for one website, five message templates, 3 social networks (equal distribution), 2 mediums (equal distribution), with and without images (equal distribution), for 10 days and 3 messages per network per day' do
    message_generation_parameter_set = MessageGenerationParameterSet.new do |m|
      m.social_network_choices = [:facebook, :twitter, :instagram]
      m.social_network_distribution = :equal
      m.medium_choices = [:ad, :organic]
      m.medium_distribution = :equal
      m.image_present_choices = [:with, :without]
      m.image_present_distribution = :equal
      m.period_in_days = 10
      m.number_of_messages_per_social_network = 3
    end
    @experiment.message_generation_parameter_set = message_generation_parameter_set

    @message_factory.create(@experiment) 
    messages = @experiment.messages

    expect(messages.count).to eq(message_generation_parameter_set.expected_generated_message_count)
    messages.all.each do |message|
      expect(message.message_generating).to eq(@experiment)
    end
    # Are the messages equally distributed across social networks?
    expect_equal_distribution(messages.group_by { |message| message.message_template.platform })
    # Are the messages equally distributed across mediums?
    expect_equal_distribution(messages.group_by { |message| message.medium })
    # Are the messages equally distributed across image present choices?
    expect_equal_distribution(messages.group_by { |message| message.image_present })
    
    # Tag matching
    # Do the websites selected for each message belong to the set of images matched to the message template?
    messages.all.each do |message|
      expect(@tag_matcher.match(Website, message.message_template.tag_list)).to include(message.promotable)
    end
    # Do the images selected for each message belong to the set of images matched to the message template?
    messages.all.each do |message|
      expect(@tag_matcher.match(Image, message.message_template.tag_list)).to include(message.image) if message.image_present == :with
    end
    
    # Social media profile picking
    messages.all.each do |message|
      expect(message.social_media_profile).to eq(@suitable_social_media_profiles[1])
    end
  end

  it 'recreates the messages each time' do
    message_generation_parameter_set = MessageGenerationParameterSet.new do |m|
      m.social_network_choices = ['facebook']
      m.social_network_distribution = :equal
      m.medium_choices = ['ad']
      m.medium_distribution = :equal
      m.image_present_choices = ['with']
      m.image_present_distribution = :equal
      m.period_in_days = 10
      m.number_of_messages_per_social_network = 3
    end
    @experiment.message_generation_parameter_set = message_generation_parameter_set

    @message_factory.create(@experiment)
    @message_factory.create(@experiment)
    
    messages = Message.all
    expect(messages.count).to eq(message_generation_parameter_set.expected_generated_message_count)
  end

  def expect_equal_distribution(grouped_messages)
    keys = grouped_messages.keys
    (0...(keys.count - 1)).each do |index|
      expect(grouped_messages[keys[index]].length == grouped_messages[keys[index + 1]].length)
    end
  end
end