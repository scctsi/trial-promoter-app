require 'rails_helper'

RSpec.describe MessageTemplate do
  it { is_expected.to validate_presence_of :content }
  it { is_expected.to validate_presence_of :platform }
  it { should enumerize(:platform).in(:twitter, :facebook).with_predicates(true) }

  context 'containing variables' do
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
  
  context 'generating messages' do
    it 'replaces the variables in the message template with the value of the attributes of the supplied clinical trial and shortens the url of the supplied clinical trial' do
      clinical_trial = ClinicalTrial.new(pi_first_name: 'First', pi_last_name: 'Last', disease: 'Disease', url: 'http://www.url.com')
      message_template = MessageTemplate.new(content: 'This is a message template containing {pi_first_name}, {pi_last_name}, { Disease}, {URL} variables')
      shortened_url = ''
      message = ''
      VCR.use_cassette('message_template/generating_messages') do
        shortened_url = UrlShortener.new.shorten(clinical_trial.url)
      end
      
      VCR.use_cassette('message_template/generating_messages') do
        message = message_template.generate_message(clinical_trial)
      end

      expect(message.text).to eq("This is a message template containing #{clinical_trial.pi_first_name}, #{clinical_trial.pi_last_name}, #{clinical_trial.disease}, #{shortened_url} variables")
    end
  end

# it { is_expected.to have_many :messages }
#   it 'saves the content as a string' do
#     message_template = MessageTemplate.new(:initial_id => "1", :platform => "twitter", :message_type => "awareness", :content => 'Some content')

#     message_template.save
#     message_template.reload

#     expect(message_template.content).to eq('Some content')
#   end

#   it 'saves the content as an array (used for Google, YouTube ads)' do
#     message_template = MessageTemplate.new(:initial_id => "1", :platform => "twitter", :message_type => "awareness", :content => ['Headline', 'Description Line 1', 'Description Line 2'])

#     message_template.save
#     message_template.reload

#     expect(message_template.content).to eq(['Headline', 'Description Line 1', 'Description Line 2'])
#   end
end
