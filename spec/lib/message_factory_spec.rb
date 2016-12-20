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
    messages.each do |message|
      expect(message.message_generating).to eq(@experiment)
    end
    # Are the messages equally distributed across social networks?
    expect_equal_distribution(messages.group_by { |message| message.message_template.platform })
    # Are the messages equally distributed across mediums?
    expect_equal_distribution(messages.group_by { |message| message.medium })
    # Are the messages equally distributed across image present choices?
    expect_equal_distribution(messages.group_by { |message| message.image_present })
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