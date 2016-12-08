require 'rails_helper'

RSpec.describe MessageFactory do
  before do
    @experiment = create(:experiment)
    create(:website, experiment_list: @experiment.to_param)
    SocialNetworks::SUPPORTED_NETWORKS.each do |social_network|
      create_list(:message_template, 5, platform: social_network, experiment_list: @experiment.to_param)
    end
    @message_factory = MessageFactory.new
  end

  it 'creates a set of messages for one website, five message templates, 1 social network (equal distribution), 1 medium (equal distribution), with images (equal distribution), for 10 days and 3 messages per network per day' do
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

    @message_factory.create(@experiment, message_generation_parameter_set) 
    
    messages = Message.all
    expect(messages.count).to eq(message_generation_parameter_set.expected_generated_message_count)
    expect((messages.select { |message| message.message_template.platform != :facebook }).count).to eq(0)
  end

  it 'creates a set of messages for one website, five message templates, 3 social networks (equal distribution), 2 mediums (equal distribution), with and without images (equal distribution), for 10 days and 3 messages per network per day' do
    message_generation_parameter_set = MessageGenerationParameterSet.new(
      social_network_choices: ['facebook', 'twitter', 'instagram'],
      social_network_distribution: :equal,
      medium_choices: ['ad', 'organic'],
      medium_distribution: :equal,
      image_present_choices: ['with', 'without'],
      image_present_distribution: :equal,
      period_in_days: 10,
      number_of_messages_per_social_network: 3
    )

    @message_factory.create(@experiment, message_generation_parameter_set) 

    messages = Message.all
    expect(messages.count).to eq(message_generation_parameter_set.expected_generated_message_count)
    # Are the messages equally distributed across social networks?
    messages_grouped_by_social_network = messages.group_by { |message| message.message_template.platform }
    keys = messages_grouped_by_social_network.keys
    # TODO: This test should be fixed to work with any number of social networks
    expect(messages_grouped_by_social_network[keys[0]].length == messages_grouped_by_social_network[keys[1]].length)
    expect(messages_grouped_by_social_network[keys[1]].length == messages_grouped_by_social_network[keys[2]].length)
    # Are the messages equally distributed across mediums?
    messages_grouped_by_medium = messages.group_by { |message| message.medium }
    keys = messages_grouped_by_medium.keys
    expect(messages_grouped_by_medium[keys[0]].length == messages_grouped_by_medium[keys[1]].length)
    # Are the messages equally distributed across image present choices?
    messages_grouped_by_image_present = messages.group_by { |message| message.image_present }
    keys = messages_grouped_by_image_present.keys
    expect(messages_grouped_by_image_present[keys[0]].length == messages_grouped_by_image_present[keys[1]].length)
  end
end