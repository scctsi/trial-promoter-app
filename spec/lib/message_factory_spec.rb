require 'rails_helper'

RSpec.describe MessageFactory do
  before do
    @experiment = create(:experiment)
    @suitable_social_media_profiles = create_list(:social_media_profile, 3)
    @suitable_social_media_profiles.each { |social_media_profile| @experiment.social_media_profiles << social_media_profile }
    @experiment.save
    #tag_lists = [['tag-1'], ['tag-4', 'tag-5', 'tag-6'], ['tag-2', 'tag-3', 'tag-4']]
    tag_lists = [['tag-1']]
    TrialPromoter::SUPPORTED_NETWORKS.each do |social_network|
      # Randomly tag each message template with a set of tags taken from tag_lists
      tag_list = tag_lists.sample
      create_list(:message_template, 5, platform: social_network, experiment_list: @experiment.to_param, tag_list: tag_list)
      # Create websites and images that can be matched up with the help of a Tag Matcher
      create_list(:image, 3, experiment_list: @experiment.to_param, tag_list: tag_list)
      create_list(:website, 3, experiment_list: @experiment.to_param, tag_list: tag_list)
    end
    # Set up tag matching
    @tag_matcher = TagMatcher.new
    # Set up social media profile picking
    @social_media_profile_picker = SocialMediaProfilePicker.new
    allow(@social_media_profile_picker).to receive(:pick).with(@suitable_social_media_profiles, Message).and_return(@suitable_social_media_profiles[1])
    @message_factory = MessageFactory.new(@tag_matcher, @social_media_profile_picker)
    # Set up Pusher mocks
    @pusher_channel = double()
    allow(Pusher).to receive(:[]).with('progress').and_return(@pusher_channel)
    allow(@pusher_channel).to receive(:trigger)
  end

  it 'can be initialized with a tag matcher and a social media profile picker' do
    @message_factory = MessageFactory.new(@tag_matcher, @social_media_profile_picker)
    
    expect(@message_factory.tag_matcher).to eq(@tag_matcher)
    expect(@message_factory.social_media_profile_picker).to eq(@social_media_profile_picker)
  end
  
  it 'creates a set of messages for one website, five message templates, 1 social network (equal distribution), 1 medium (equal distribution), with no images, for 1 day and 1 message per network per day' do
    @experiment.posting_times = "12:30 PM"
    @experiment.save
    message_generation_parameter_set = MessageGenerationParameterSet.new do |m|
      m.social_network_choices = [:facebook]
      m.social_network_distribution = :equal
      m.medium_choices = ['ad']
      m.medium_distribution = :equal
      m.image_present_choices = ['without']
      m.image_present_distribution = :equal
      m.period_in_days = 1
      m.number_of_messages_per_social_network = 1
    end
    @experiment.message_generation_parameter_set = message_generation_parameter_set

    @message_factory.create(@experiment)
    
    messages = Message.all.order('created_at ASC')
    expect(messages.count).to eq(message_generation_parameter_set.expected_generated_message_count)
    expect((messages.select { |message| message.message_template.platform != :facebook }).count).to eq(0)
    # Have the pusher events been triggered?
    expect(@pusher_channel).to have_received(:trigger).exactly(message_generation_parameter_set.expected_generated_message_count).times.with('progress', {:value => an_instance_of(Fixnum), :total => message_generation_parameter_set.expected_generated_message_count, :event => 'Message generated'})

    # Has the scheduled date and time been set correctly?
    publish_date_time = @experiment.message_distribution_start_date
    publish_date_time = publish_date_time.change({ hour: 12, min: 30, sec: 0 })
    messages.all.each do |message|
      expect(message.scheduled_date_time).to eq(publish_date_time)
      publish_date_time += 1.day
    end

    # Tag matching
    # Do the websites selected for each message belong to the set of images matched to the message template?
    messages.all.each do |message|
      expect(@tag_matcher.match(Website.belonging_to(@experiment), message.message_template.tag_list)).to include(message.promotable)
    end
    # Do the images selected for each message belong to the set of images matched to the message template?
    messages.all.each do |message|
      expect(@tag_matcher.match(Image.belonging_to(@experiment), message.message_template.tag_list)).to include(message.image) if message.image_present == :with
    end
  end

  it 'creates a set of messages for one website, five message templates, 3 social networks (equal distribution), 2 mediums (equal distribution), with and without images (equal distribution), for 3 days and 3 messages per network per day' do
    @experiment.posting_times = "12:30 PM,5:30 PM,6:32 PM"
    @experiment.save
    message_generation_parameter_set = MessageGenerationParameterSet.new do |m|
      m.social_network_choices = [:facebook, :twitter, :instagram]
      m.social_network_distribution = :equal
      m.medium_choices = [:ad, :organic]
      m.medium_distribution = :equal
      m.image_present_choices = [:with]
      m.image_present_distribution = :equal
      m.period_in_days = 3
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
      expect(message.promotable).not_to be_nil
      expect(@tag_matcher.match(Website.belonging_to(@experiment), message.message_template.tag_list)).to include(message.promotable)
    end
    # Do the images selected for each message belong to the set of images matched to the message template?
    messages.all.each do |message|
      expect(message.image).not_to be_nil if message.image_present == :with
      expect(@tag_matcher.match(Image.belonging_to(@experiment), message.message_template.tag_list)).to include(message.image) if message.image_present == :with
    end
    
    # Social media profile picking
    messages.all.each do |message|
      expect(message.social_media_profile).to eq(@suitable_social_media_profiles[1])
    end

    # Has the scheduled date and time been set correctly?
    # TODO: How do I test this efficiently?
  end

  it 'recreates the messages each time' do
    @experiment.posting_times = "12:30 PM,5:30 PM,6:32 PM"
    @experiment.save
    message_generation_parameter_set = MessageGenerationParameterSet.new do |m|
      m.social_network_choices = ['facebook']
      m.social_network_distribution = :equal
      m.medium_choices = ['ad']
      m.medium_distribution = :equal
      m.image_present_choices = ['with']
      m.image_present_distribution = :equal
      m.period_in_days = 1
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