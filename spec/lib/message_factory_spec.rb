require 'rails_helper'

RSpec.describe MessageFactory do
  before do
    experiment = create(:experiment)
    @websites = create(:website, experiment_list: experiment.to_param)
    @message_templates = create_list(:message_template, 5, experiment_list: experiment.to_param)
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
    expect(messages.reject { |message| message.message_template.platform == :facebook }).count.to eq(0)
  end
end