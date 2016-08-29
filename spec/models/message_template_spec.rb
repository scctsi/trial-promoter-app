# == Schema Information
#
# Table name: message_templates
#
#  id         :integer          not null, primary key
#  content    :text
#  platform   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe MessageTemplate do
  it { is_expected.to validate_presence_of :content }
  it { is_expected.to validate_presence_of :platform }
  it { is_expected.to enumerize(:platform).in(:twitter, :facebook) }
  it { is_expected.to have_many :messages }

  describe 'standardizing variables' do
    it 'downcases the pi_first_name variable' do
      message_template = MessageTemplate.new(content: 'This is a message_template containing a {PI_first_name} variable')
      
      expect(message_template.content).to eq('This is a message_template containing a {pi_first_name} variable')
    end

    it 'downcases the pi_last_name variable' do
      message_template = MessageTemplate.new(content: 'This is a message_template containing a {pi_last_NAME} variable')
      
      expect(message_template.content).to eq('This is a message_template containing a {pi_last_name} variable')
    end

    it 'downcases the disease variable' do
      message_template = MessageTemplate.new(content: 'This is a message_template containing a {Disease} variable')
      
      expect(message_template.content).to eq('This is a message_template containing a {disease} variable')
    end

    it 'downcases the url variable' do
      message_template = MessageTemplate.new(content: 'This is a message_template containing a {URL} variable')
      
      expect(message_template.content).to eq('This is a message_template containing a {url} variable')
    end
    
    it 'strips out whitespace in the pi_first_name variable' do
      message_template = MessageTemplate.new(content: 'This is a message_template containing a { PI_first_name } variable with whitespace')
      
      expect(message_template.content).to eq('This is a message_template containing a {pi_first_name} variable with whitespace')
    end

    it 'strips out whitespace in the pi_last_name variable' do
      message_template = MessageTemplate.new(content: 'This is a message_template containing a {pi_last_NAME  } variable with whitespace')
      
      expect(message_template.content).to eq('This is a message_template containing a {pi_last_name} variable with whitespace')
    end

    it 'strips out whitespace in the disease variable' do
      message_template = MessageTemplate.new(content: 'This is a message_template containing a {  Disease} variable with whitespace')
      
      expect(message_template.content).to eq('This is a message_template containing a {disease} variable with whitespace')
    end

    it 'strips out whitespace in the url variable' do
      message_template = MessageTemplate.new(content: 'This is a message_template containing a { url } variable with whitespace')
      
      expect(message_template.content).to eq('This is a message_template containing a {url} variable with whitespace')
    end
    
    it 'strips out whitespace and downcases multiple and different variables' do
      message_template = MessageTemplate.new(content: 'This is a message_template containing {  Disease}, {PI_first_name }, {PI_LAST_NAME  } variables')

      expect(message_template.content).to eq('This is a message_template containing {disease}, {pi_first_name}, {pi_last_name} variables')
    end
    
    it 'strips out whitespace and downcases multiple and duplicate variables' do
      message_template = MessageTemplate.new(content: 'This is a message_template containing {  Disease}, {PI_first_name }, {PI_LAST_NAME  } variables which are duplicated here: {  Disease}, {PI_first_name }, {PI_LAST_NAME  }')

      expect(message_template.content).to eq('This is a message_template containing {disease}, {pi_first_name}, {pi_last_name} variables which are duplicated here: {disease}, {pi_first_name}, {pi_last_name}')
    end
  end
end
