require 'rails_helper'

RSpec.describe MessageFactory do
  before do
    @experiment = create(:experiment)
    @suitable_social_media_profiles = create_list(:social_media_profile, 3)
    @suitable_social_media_profiles.each { |social_media_profile| @experiment.social_media_profiles << social_media_profile }
    @experiment.save
    message_templates = create_list(:message_template, 5, platforms: TrialPromoter::SUPPORTED_NETWORKS, experiment_list: @experiment.to_param)
    # Create 2 images for each message template's image pool
    message_templates.each do |message_template|
      images = create_list(:image, 2, experiment_list: @experiment.to_param)
      message_template.image_pool = images.map(&:id)
      message_template.save
    end
    # Add some hashtags to the first 3 message templates
    message_templates[0..2].each do |message_template]
      random_hashtags = ['#hashtag1,#hashtag2,#hashtag3','#hashtag1,#hashtag4,#hashtag5','#hashtag6,#hashtag7,#hashtag8']
      message_template.hashtags = random_hashtags.sample
      message_template.save
    end
    MessageTemplate.all.each do |message_template|
      images = create_list(:image, 2, experiment_list: @experiment.to_param)
      message_template.image_pool = images.map(&:id)
      message_template.save
    end
    # Set up social media profile picking
    @social_media_profile_picker = SocialMediaProfilePicker.new
    allow(@social_media_profile_picker).to receive(:pick).with(@suitable_social_media_profiles, Symbol, Symbol).and_return(@suitable_social_media_profiles[1])
    @message_factory = MessageFactory.new(@social_media_profile_picker)
    # Set up Pusher mocks
    @pusher_channel = double()
    allow(Pusher).to receive(:[]).with('progress').and_return(@pusher_channel)
    allow(@pusher_channel).to receive(:trigger)
  end

  it 'can be initialized with a social media profile picker' do
    @message_factory = MessageFactory.new(@social_media_profile_picker)
    
    expect(@message_factory.social_media_profile_picker).to eq(@social_media_profile_picker)
  end
  
  it 'returns a hash of parameters for message generation' do
    @experiment.facebook_posting_times = "12:30 PM"
    @experiment.save
    message_generation_parameter_set = MessageGenerationParameterSet.new do |m|
      m.social_network_choices = [:facebook]
      m.medium_choices = ['ad']
      m.image_present_choices = :no_messages
      m.number_of_cycles = 1
      m.number_of_messages_per_social_network = 1
    end
    @experiment.message_generation_parameter_set = message_generation_parameter_set

    parameters = @message_factory.get_message_generation_parameters(@experiment)

    expect(parameters[:message_constructor]).not_to be_nil
    expect(parameters[:number_of_cycles]).to eq(@experiment.message_generation_parameter_set.number_of_cycles)
    expect(parameters[:number_of_messages_per_day]).to eq(@experiment.message_generation_parameter_set.number_of_messages_per_social_network)
    expect(parameters[:platforms]).to eq(@experiment.message_generation_parameter_set.social_network_choices)
    expect(parameters[:mediums]).to eq(@experiment.message_generation_parameter_set.medium_choices)
    expect(parameters[:message_templates]).to eq(MessageTemplate.belonging_to(@experiment))
    expect(parameters[:posting_times]).to eq(@experiment.posting_times_as_datetimes)
    expect(parameters[:total_count]).to eq(@experiment.message_generation_parameter_set.expected_generated_message_count(parameters[:message_templates].count))
    expect(parameters[:social_media_profiles]).to eq(@experiment.social_media_profiles)
  end

  it 'creates a set of messages given five message templates, 1 social network, 1 medium, images for all messages, 1 cycle, 1 message per network per day and no hashtags' do
    @experiment.facebook_posting_times = "12:30 PM"
    @experiment.save
    message_generation_parameter_set = MessageGenerationParameterSet.new do |m|
      m.social_network_choices = [:facebook]
      m.medium_choices = ['ad']
      m.image_present_choices = :all_messages
      m.number_of_cycles = 1
      m.number_of_messages_per_social_network = 1
    end
    @experiment.message_generation_parameter_set = message_generation_parameter_set
    expected_generated_message_count = message_generation_parameter_set.expected_generated_message_count(MessageTemplate.count)

    @message_factory.create(@experiment)
    
    messages = Message.all.order('created_at ASC')
    # Have the correct number of messages been generated?
    expect(messages.count).to eq(expected_generated_message_count)
    # Is every message for the right platform?
    expect((messages.select{ |message| message.platform != :facebook }).count).to eq(0)
    # Is every message for the right medium?
    expect((messages.select{ |message| message.medium != :ad }).count).to eq(0)
    # Does every message have a promoted_website_url?
    expect((messages.select{ |message| message.promoted_website_url.nil? }).count).to eq(0)
    # Does every message have a suitable social media profile selected?
    messages.each do |message|
      expect(message.social_media_profile).to eq(@suitable_social_media_profiles[1])
    end
    # Were the pusher events triggered?
    expect(@pusher_channel).to have_received(:trigger).exactly(expected_generated_message_count).times.with('progress', {:value => an_instance_of(Fixnum), :total => expected_generated_message_count, :event => 'Message generated'})

    # Has the scheduled date and time been set correctly?
    publish_date_time = @experiment.message_distribution_start_date
    publish_date_time = publish_date_time.change({ hour: 12, min: 30, sec: 0 })
    messages.all.each do |message|
      expect(message.scheduled_date_time).to eq(publish_date_time)
      publish_date_time += 1.day
    end

    # Is the image selected for each message taken from the image pool for the corresponding message template?
    messages.all.each do |message|
      expect(message.message_template.image_pool.include?(message.image.id)).to be true
    end

    # Is one hashtag Random hashtags
  end

  it 'creates a set of messages given five message templates, 3 social networks, 2 mediums, images for all messages, 3 cycles, 5 messages per network per day and selectes random hashtags where feasible' do
    @experiment.facebook_posting_times = "12:30 PM"
    @experiment.save
    message_generation_parameter_set = MessageGenerationParameterSet.new do |m|
      m.social_network_choices = [:facebook, :instagram, :twitter]
      m.medium_choices = ['ad', 'organic']
      m.image_present_choices = :all_messages
      m.number_of_cycles = 3
      m.number_of_messages_per_social_network = 5
    end
    @experiment.message_generation_parameter_set = message_generation_parameter_set
    expected_generated_message_count = message_generation_parameter_set.expected_generated_message_count(MessageTemplate.count)

    @message_factory.create(@experiment)
    
    messages = Message.all.order('created_at ASC')
    # Have the correct number of messages been generated?
    expect(messages.count).to eq(expected_generated_message_count)
    # Was every message template used in every cycle (3)?
    # Basically each message template should have been used 3 * 6 times (number_of_cycles * platform count * medium count)
    messages_grouped_by_message_template = messages.group_by { |message| message.message_template.id }
    messages_grouped_by_message_template.each{ |message_template_id, messages_using_message_template| expect(messages_using_message_template.count).to eq(18) }
    # Are the message templates with their platform and medium distributed equally?
    messages_grouped_by_message_template_platform_and_medium = messages.group_by { |message| message.message_template.id.to_s + message.platform.to_s + message.medium.to_s }
    expect_equal_distribution(messages_grouped_by_message_template_platform_and_medium)

    # Does every message have a suitable social media profile selected?
    messages.each do |message|
      expect(message.social_media_profile).to eq(@suitable_social_media_profiles[1])
    end
    # Does every message have a promoted_website_url?
    expect((messages.select{ |message| message.promoted_website_url.nil? }).count).to eq(0)
    # Were the pusher events triggered?
    expect(@pusher_channel).to have_received(:trigger).exactly(expected_generated_message_count).times.with('progress', {:value => an_instance_of(Fixnum), :total => expected_generated_message_count, :event => 'Message generated'})

    # # Has the scheduled date and time been set correctly?
    # TODO: Not sure how I can test this efficiently.

    # Is the image selected for each message taken from the image pool for the corresponding message template?
    messages.all.each do |message|
      expect(message.message_template.image_pool.include?(message.image.id)).to be true
    end
    
    # # Random hashtags
  end

  it 'recreates the messages each time' do
    @experiment.facebook_posting_times = "12:30 PM"
    @experiment.save
    message_generation_parameter_set = MessageGenerationParameterSet.new do |m|
      m.social_network_choices = [:facebook]
      m.medium_choices = ['ad']
      m.image_present_choices = :no_messages
      m.number_of_cycles = 1
      m.number_of_messages_per_social_network = 1
    end
    @experiment.message_generation_parameter_set = message_generation_parameter_set
    expected_generated_message_count = message_generation_parameter_set.expected_generated_message_count(MessageTemplate.count)

    @message_factory.create(@experiment)
    @message_factory.create(@experiment)
    
    messages = Message.all
    expect(messages.count).to eq(expected_generated_message_count)
  end

  def expect_equal_distribution(grouped_messages)
    keys = grouped_messages.keys
    (0...(keys.count - 1)).each do |index|
      expect(grouped_messages[keys[index]].length == grouped_messages[keys[index + 1]].length)
    end
  end
end